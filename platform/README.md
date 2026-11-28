# CTF Pilot's Kubernetes Platform

> [!IMPORTANT]
> You are leaving the automated CTF Pilot setup and entering a more advanced manual setup.  
> This requires knowledge of Kubernetes, Terraform/OpenTofu, and cloud infrastructure management.  
> If you are not comfortable with these technologies, it is recommended to use the automated setup provided by CTF Pilot.  
> Learn more about the automated setup in the [CTFp main README](../README.md).

This directory contains deployment configuration for the scoreboard and related services, such as [ctfd](https://github.com/ctfpilot/ctfd) and [ctfd-manager](https://github.com/ctfpilot/ctfd-manager)

## Pre-requisites

The following software needs to be installed on your local machine:

- [Terraform](https://www.terraform.io/downloads.html) / [OpenTofu](https://opentofu.org)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) (For interacting with the Kubernetes cluster)

The following services are required, in order to deploy the services to the cluster:

- A Kubernetes cluster (Deployed using the [CTF Pilot's Kubernetes Cluster on Hetzner Cloud](../cluster/README.md) guide or other means)
- Correctly deployed [ArgoCD](https://argo-cd.readthedocs.io/) within the Kubernetes cluster.

> [!NOTE]
> The platform has only been tested within the CTFp system.  
> We recommend at least having [the Ops](../ops/README.md) deployed, as this project relies on those configurations.

## Setup

### Redis label upgrade

Fresh installations can skip this section. Apply ops before upgrading platform. These steps apply to the default Redis Operator v0.25.0. Schedule a maintenance window and verify that Redis is healthy and that you can restore any data you need. The operator copies labels from its custom resources into selectors, including the immutable Sentinel StatefulSet selector. Prepare the existing pods before applying the Terraform changes so the new service selectors can still find them.

Set `CTFP_CONTEXT` to the context for the target cluster and confirm both Redis custom resources and their pods exist. Resolve any intentional pause on either resource before starting. The commands use the namespaces and names from this configuration.

```bash
(
  set -eu
  kubectl --context "${CTFP_CONTEXT:?Set CTFP_CONTEXT}" -n ctfd get redisreplication redis-replication
  kubectl --context "$CTFP_CONTEXT" -n traefik get rediscluster redis-cluster

  kubectl --context "$CTFP_CONTEXT" -n ctfd annotate redisreplication redis-replication --overwrite \
    redisreplication.opstreelabs.in/skip-reconcile=true
  kubectl --context "$CTFP_CONTEXT" -n traefik annotate rediscluster redis-cluster --overwrite \
    rediscluster.opstreelabs.in/skip-reconcile=true

  kubectl --context "$CTFP_CONTEXT" -n ctfd label pods -l 'app in (redis-replication,redis-replication-s)' --overwrite \
    app.kubernetes.io/name=redis app.kubernetes.io/component=platform \
    app.kubernetes.io/part-of=ctfpilot ctfpilot.com/component=platform
  kubectl --context "$CTFP_CONTEXT" -n traefik label pods -l 'app in (redis-cluster-leader,redis-cluster-follower)' --overwrite \
    app.kubernetes.io/name=redis app.kubernetes.io/component=platform \
    app.kubernetes.io/part-of=ctfpilot ctfpilot.com/component=platform

  kubectl --context "$CTFP_CONTEXT" -n ctfd delete statefulset redis-replication-s --cascade=orphan --ignore-not-found
)
```

Generate and apply the platform Terraform plan while reconciliation is paused. The plan checks the affected pods and Sentinel selector. If Kubernetes replaces any of those pods after planning, label the replacements and generate a new plan before applying. If the apply fails, inspect which Redis resources were updated and correct the failed plan before resuming reconciliation. After a successful apply, resume reconciliation and check the Sentinel rollout and Redis endpoints.

```bash
(
  set -eu
  : "${CTFP_CONTEXT:?Set CTFP_CONTEXT}"
  kubectl --context "$CTFP_CONTEXT" -n ctfd annotate redisreplication redis-replication \
    redisreplication.opstreelabs.in/skip-reconcile-
  kubectl --context "$CTFP_CONTEXT" -n traefik annotate rediscluster redis-cluster \
    rediscluster.opstreelabs.in/skip-reconcile-
  kubectl --context "$CTFP_CONTEXT" -n ctfd wait --for=create statefulset/redis-replication-s --timeout=5m
  kubectl --context "$CTFP_CONTEXT" -n ctfd rollout status statefulset/redis-replication-s --timeout=5m
  kubectl --context "$CTFP_CONTEXT" -n ctfd get endpointslices
  kubectl --context "$CTFP_CONTEXT" -n traefik get endpointslices
)
```

Copy the `tfvars/template.tfvars` file to `tfvars/data.tfvars` and edit the file with your own values.  
The [`tfvars/template.tfvars`](tfvars/template.tfvars) file contains further information on each variable.

> [!IMPORTANT]
> Make sure you generate the backend configuration file before creating the cluster.  
> See the [backend generation instructions](../backend/README.md) for more information.
>
> You will also need to set the following environment variables for authentication to the S3 backend:
> - `AWS_ACCESS_KEY_ID`
> - `AWS_SECRET_ACCESS_KEY`
>
> See [OpenTofub backend S3 configuration](https://opentofu.org/docs/language/settings/backends/s3/) for more information.

Run the following command to apply the ressources to the Kubernetes cluster:

```bash
tofu init -backend-config=../backend/generated/platform.hcl
tofu apply --var-file tfvars/data.tfvars
```

### Destroying the platform

To destroy the deployed platform, run the following command:

```bash
tofu destroy --var-file tfvars/data.tfvars
```
