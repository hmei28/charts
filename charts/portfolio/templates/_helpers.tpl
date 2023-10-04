{{/*
Expand the name of the chart.
*/}}
{{- define "names.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "names.fullname" -}}
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
{{- define "names.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Kubernetes standard labels
*/}}
{{- define "labels.standard" -}}
app.kubernetes.io/name: {{ include "names.name" . }}
helm.sh/chart: {{ include "names.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Labels to use on deploy.spec.selector.matchLabels and svc.spec.selector
*/}}
{{- define "labels.matchLabels" -}}
app.kubernetes.io/name: {{ include "names.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}



{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "portfolio.postgresql.fullname" -}}
{{- if .Values.postgresql.enabled }}
    {{- $name := "postgresql" -}}
    {{- if contains $name .Release.Name -}}
        {{- .Release.Name | trunc 63 | trimSuffix "-" -}}
    {{- else -}}
        {{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return the Postgresql Hostname
*/}}
{{- define "portfolio.databaseHost" -}}
{{- if .Values.postgresql.enabled }}
    {{- printf "%s" (include "portfolio.postgresql.fullname" .) -}}
{{- else -}}
    {{- printf "%s" .Values.externalDatabase.host -}}
{{- end -}}
{{- end -}}

{{/*
Return the Postgresql Port
*/}}
{{- define "portfolio.databasePort" -}}
    {{- printf "5432" -}}
{{- end -}}

{{/*
Return the Postgresql Database Name
*/}}
{{- define "portfolio.databaseName" -}}
{{- if .Values.postgresql.enabled }}
    {{- printf "%s" .Values.postgresql.auth.database -}}
{{- else -}}
    {{- printf "%s" .Values.externalDatabase.database -}}
{{- end -}}
{{- end -}}

{{/*
Return the Postgresql Database Name
*/}}
{{- define "portfolio.databaseUser" -}}
{{- if .Values.postgresql.enabled }}
    {{- printf "%s" .Values.postgresql.auth.username -}}
{{- else -}}
    {{- printf "%s" .Values.externalDatabase.username -}}
{{- end -}}
{{- end -}}


{{/*
Return the postgresql Secret Name
*/}}
{{- define "postgresql.databaseSecretName" -}}
{{- if .Values.postgresql.enabled }}
    {{- if .Values.postgresql.auth.existingSecret -}}
        {{- printf "%s" .Values.postgresql.auth.existingSecret -}}
    {{- else -}}
        {{- printf "%s" (include "portfolio.postgresql.fullname" .) -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return the Portfolio Secret Name
*/}}
{{- define "portfolio.secretName" -}}
{{- if .Values.existingSecret }}
    {{- printf "%s" .Values.existingSecret -}}
{{- else -}}
    {{- printf "%s" (include "names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "secret.generatePassword" -}}
{{ randAlphaNum 20 | b64enc }}
{{- end -}}


{{/*
Returns true if the ingressClassname field is supported
*/}}
{{- define "ingress.apiVersion" -}}
{{- if .Values.ingress -}}
{{- if .Values.ingress.apiVersion -}}
{{- printf "%s" .Values.ingress.apiVersion -}}
{{- else if semverCompare ">=1.19-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "networking.k8s.io/v1" -}}
{{- else if semverCompare ">=1.14-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "networking.k8s.io/v1beta1" -}}
{{- else -}}
{{- print "extensions/v1beta1" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Returns true if the ingressClassname field is supported
Usage:
{{ include "ingress.supportsIngressClassname" . }}
*/}}
{{- define "common.ingress.supportsIngressClassname" -}}
{{- if semverCompare "<1.18-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "false" -}}
{{- else -}}
{{- print "true" -}}
{{- end -}}
{{- end -}}

{{/*
Print "true" if the API pathType field is supported
Usage:
{{ include "ingress.supportsPathType" . }}
*/}}
{{- define "ingress.supportsPathType" -}}
{{- if semverCompare "<1.18-0" .Capabilities.KubeVersion.GitVersion  -}}
{{- print "false" -}}
{{- else -}}
{{- print "true" -}}
{{- end -}}
{{- end -}}


{{/*
Return true if cert-manager required annotations for TLS signed
certificates are set in the Ingress annotations
Ref: https://cert-manager.io/docs/usage/ingress/#supported-annotations
Usage:
{{ include "ingress.certManagerRequest" ( dict "annotations" .Values.path.to.the.ingress.annotations ) }}
*/}}
{{- define "ingress.certManagerRequest" -}}
{{ if or (hasKey .annotations "cert-manager.io/cluster-issuer") (hasKey .annotations "cert-manager.io/issuer") (hasKey .annotations "kubernetes.io/tls-acme") }}
    {{- true -}}
{{- end -}}
{{- end -}}
