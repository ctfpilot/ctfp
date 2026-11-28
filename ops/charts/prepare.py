"""Prepare an upstream Helm chart with CTFPilot resource labels."""
import hashlib
import json
from pathlib import Path
import subprocess
import sys
from tempfile import TemporaryDirectory

import yaml


TEMPLATE = Path(__file__).with_name("label-template.tpl")


class KubernetesYamlLoader(yaml.SafeLoader):
    # A bare "=" in an OpenAPI enum is a string in Kubernetes YAML.
    yaml_implicit_resolvers = {
        key: [(tag, regex) for tag, regex in entries if tag != "tag:yaml.org,2002:value"]
        for key, entries in yaml.SafeLoader.yaml_implicit_resolvers.items()
    }


def label_crds(chart):
    result = {}
    for file in (chart / "crds").rglob("*"):
        if file.suffix not in {".yaml", ".yml", ".json"} or not file.is_file():
            continue
        objects = list(yaml.load_all(file.read_text(), Loader=KubernetesYamlLoader))
        for resource in objects:
            if resource is None:
                continue
            if resource.get("kind") != "CustomResourceDefinition":
                raise ValueError(f"Unexpected object in chart CRDs: {file}")
            labels = resource.setdefault("metadata", {}).setdefault("labels", {})
            labels.setdefault("app.kubernetes.io/name", chart.name)
            labels.setdefault("app.kubernetes.io/component", "ops")
            labels["app.kubernetes.io/part-of"] = "ctfpilot"
            labels["ctfpilot.com/component"] = "ops"
            result[resource["metadata"]["name"]] = {
                key: labels[key] for key in (
                    "app.kubernetes.io/name", "app.kubernetes.io/component",
                    "app.kubernetes.io/part-of", "ctfpilot.com/component",
                )
            }
        file.write_text(yaml.safe_dump_all(objects, sort_keys=False))
    return result


def label_chart(chart, template):
    for source in (chart / "templates").rglob("*"):
        if source.suffix not in {".yaml", ".yml", ".json"} or source.name.startswith("_"):
            continue
        original = Path("ctfpilot-original-templates") / source.relative_to(chart / "templates")
        target = chart / original
        target.parent.mkdir(parents=True, exist_ok=True)
        source.rename(target)
        source.write_text(template.replace("__SOURCE__", json.dumps(original.as_posix()))
                          .replace("__CHART__", json.dumps(chart.name)))
    crds = label_crds(chart)
    for dependency in (chart / "charts").glob("*"):
        if dependency.is_dir():
            crds.update(label_chart(dependency, template))
        elif dependency.suffix == ".tgz":
            raise ValueError(f"Packaged chart dependency must be expanded: {dependency}")
    return crds


def prepare(query):
    chart, repository, version = (query[key] for key in ("chart", "repository", "version"))
    template = TEMPLATE.read_text()
    fingerprint = hashlib.sha256(json.dumps([chart, repository, version, template, Path(__file__).read_text()]).encode()).hexdigest()
    requested_cache = Path(query["cache"])
    cache = requested_cache.resolve()
    cache.mkdir(parents=True, exist_ok=True)
    output = cache / f"{fingerprint}.tgz"
    index = output.with_suffix(".json")
    if not output.is_file() or not index.is_file():
        with TemporaryDirectory(dir=cache) as scratch:
            scratch = Path(scratch)
            subprocess.run(["helm", "pull", chart, "--repo", repository, "--version", version,
                            "--untar", "--untardir", str(scratch)], check=True, stdout=sys.stderr)
            source = scratch / chart
            crds = label_chart(source, template)
            destination = scratch / "package"
            destination.mkdir()
            subprocess.run(["helm", "package", str(source), "--destination", str(destination)],
                           check=True, stdout=sys.stderr)
            package, = destination.glob("*.tgz")
            package.replace(output)
            catalog = scratch / "crds.json"
            catalog.write_text(json.dumps(crds))
            catalog.replace(index)
    path = str(output) if requested_cache.is_absolute() else f"./{requested_cache / output.name}"
    return {"path": path, "crds": index.read_text()}


if __name__ == "__main__":
    print(json.dumps(prepare(json.load(sys.stdin))))
