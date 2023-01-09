{{/*
Expand the name of the chart.
*/}}
{{- define "chisel.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "chisel.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "chisel.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "chisel.labels" -}}
helm.sh/chart: {{ include "chisel.chart" . }}
{{ include "chisel.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "chisel.selectorLabels" -}}
app.kubernetes.io/name: {{ include "chisel.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Custom registry name
*/}}
{{- define "customRegistry" -}}
{{- if .Values.image.customRegistry -}}
{{ printf "%s/" .Values.image.customRegistry -}}
{{- else -}}
{{ print "" }}
{{- end -}}
{{- end -}}

{{/*
Build service list
*/}}
{{- define "services" -}}
{{- $services := dict -}}
{{- $_ := set $services "default" list -}}
{{- if (eq .Values.mode "server") -}}
 {{- range .Values.clients -}}
  {{- range $serviceName, $ports := .services -}}
   {{- /* filter the relevant entries */ -}}
   {{- $newList := list -}}
   {{- range $ports -}}
    {{- if (eq .mode "to-client") -}}
     {{- $newList = append $newList . -}}
    {{- end -}}
   {{- end -}}{{- /* range $ports */ -}}
   {{- if (gt (len $newList) 0) -}}
    {{- $_ := set $services $serviceName $newList -}}
   {{- end -}}{{- /* if (gt (len $newList) 0)  */ -}}
  {{- end -}}{{- /* range services */ -}}
 {{- end -}}{{- /* range .Values.clients */ -}}
{{- else -}}
 {{- range $serviceName, $ports := .Values.services -}}
  {{- /* filter the relevant entries */ -}}
  {{- $newList := list -}}
  {{- range $ports -}}
   {{- if (eq .mode "to-server") -}}
    {{- $newList = append $newList . -}}
   {{- end -}}
  {{- end -}}{{- /* range $ports */ -}}
  {{- if (gt (len $newList) 0) -}}
   {{- $_ := set $services $serviceName $newList -}}
  {{- end -}}{{- /* if (gt (len $newList) 0)  */ -}}
 {{- end -}}{{- /* range services */ -}}
{{- end -}}
{{ toJson $services }}
{{- end -}}