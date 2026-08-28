{{- define "harness-lemmings.fullname" -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "harness-lemmings.labels" -}}
app.kubernetes.io/name: harness-lemmings
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "harness-lemmings.selectorLabels" -}}
app.kubernetes.io/name: harness-lemmings
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
