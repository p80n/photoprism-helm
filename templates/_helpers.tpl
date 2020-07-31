{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "photoprism.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "photoprism.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "photoprism.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "photoprism.labels" -}}
app.kubernetes.io/name: {{ include "photoprism.name" . }}
helm.sh/chart: {{ include "photoprism.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/**************************************************************************/}}
{{/* Return an appropriate DSN depending on the database type */}}
{{- define "photoprism.databaseDSN" -}}

  {{- if eq .Values.database.driver "sqlite" -}}

    {{- if and .Values.persistence.enabled .Values.persistence.storagePath -}}
      {{- printf "%s/photoprism.sqlite" .Values.persistence.storagePath }}
    {{- else -}}
      'photoprism.sqlite'
    {{- end -}}

  {{- else -}}  {{/* mysql driver */}}

    {{- with .Values.database }}
      {{- printf "%s:%s@tcp(%s:%d)/%s?parseTime=true" .user .password .host ( .port | default 3306 | int) .name -}}
    {{- end -}}
    {{/* cast port, an int, to int, because of this bug: https://github.com/helm/helm/issues/1707 */}}

  {{- end -}}

{{- end -}}

