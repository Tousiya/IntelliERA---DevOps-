{{/*
Expand the name of the chart.
*/}}
{{- define "intelliera-devops.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a fully qualified app name.
*/}}
{{- define "intelliera-devops.fullname" -}}
{{- include "intelliera-devops.name" . }}
{{- end }}
