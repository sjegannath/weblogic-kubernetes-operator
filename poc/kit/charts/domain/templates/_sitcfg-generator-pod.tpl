{{/* vim: set filetype=mustache: */}}

{{/*
Prints out the extra pod container properties that a sit cfg generator pod template needs
*/}}
{{- define "domain.sitCfgGeneratorPodTemplateExtraContainerProperties" -}}
command:
- /weblogic-operator/scripts/generateSitCfg.sh
env:
- name: DOMAIN_UID
  value: {{ .domainUID }}
- name: DOMAIN_HOME
  value: {{ .podDomainHomeDir }}
- name: DOMAIN_LOGS
  value: {{ .podDomainLogsDir }}
- name: SITCFG_NAME
  value: {{ .templateName }}
- name: DOMAINS_NAMESPACE
  value: {{ .domainsNamespace }}
{{- if .extraEnv }}
{{ toYaml .extraEnv | trim | indent 0 }}
{{- end }}
livenessProbe:
  exec:
    command:
    - /weblogic-operator/scripts/sitCfgGeneratorLivenessProbe.sh
  failureThreshold: 25
  initialDelaySeconds: 30
  periodSeconds: 10
  successThreshold: 1
  timeoutSeconds: 5
readinessProbe:
  exec:
    command:
    - /weblogic-operator/scripts/sitCfgGeneratorReadinessProbe.sh
  failureThreshold: 1
  initialDelaySeconds: 2
  periodSeconds: 5
  successThreshold: 1
  timeoutSeconds: 5
{{- if .extraContainerProperties }}
{{ toYaml .extraContainerProperties | trim | indent 0 }}
{{- end }}
{{- end }}

{{/*
Creates a pod template that generates a situational configuration for a weblogic domain.
*/}}
{{- define "domain.sitCfgGeneratorPodTemplate" -}}
{{- $extraContainerProperties := include "domain.sitCfgGeneratorPodTemplateExtraContainerProperties" . | fromYaml -}}
{{- $args := merge (dict) (omit . "extraContainerProperties") -}}
{{- $ignore := set $args "podName" "sitcfg-generator" -}}
{{- $ignore := set $args "extraContainerProperties" $extraContainerProperties -}}
{{- include "domain.weblogicPod" $args }}
{{- end }}