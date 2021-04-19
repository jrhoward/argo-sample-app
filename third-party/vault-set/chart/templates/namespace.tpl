apiVersion: v1
kind: Namespace
metadata:
  annotations:
    helm.sh/hook: pre-install
    helm.sh/resource-policy: keep
  name: {{ .Values.namespacePass }}