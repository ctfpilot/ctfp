{{- $manifest := tpl (.Files.Get __SOURCE__) . -}}
{{- range regexSplit "(?m)^---(?:[ \t]+#[^\r\n]*)?[ \t]*\r?$" $manifest -1 }}
  {{- if trim . }}
    {{- $object := fromYaml . }}
    {{- if hasKey $object "Error" }}
      {{- fail (printf "%s: %s" __SOURCE__ $object.Error) }}
    {{- end }}
    {{- if $object.apiVersion }}
      {{- $metadata := $object.metadata | default dict }}
      {{- $labels := $metadata.labels | default dict }}
      {{- $_ := set $labels "app.kubernetes.io/part-of" "ctfpilot" }}
      {{- $_ := set $labels "ctfpilot.com/component" "ops" }}
      {{- if not (get $labels "app.kubernetes.io/name") }}
        {{- $_ := set $labels "app.kubernetes.io/name" __CHART__ }}
      {{- end }}
      {{- if not (get $labels "app.kubernetes.io/component") }}
        {{- $_ := set $labels "app.kubernetes.io/component" "ops" }}
      {{- end }}
      {{- $_ := set $metadata "labels" $labels }}
      {{- $_ := set $object "metadata" $metadata }}
---
{{ toYaml $object }}
    {{- end }}
  {{- end }}
{{- end }}
