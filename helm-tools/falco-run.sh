#!/bin/bash

helm upgrade --install falco falcosecurity/falco \
  --namespace falco \
  --reuse-values \
  --set falcosidekick.enabled=true \
  --set falcosidekick.config.discord.webhookurl="https://discord.com/api/webhooks/1515414420992561334/mNdYkGh65Kc-h3HbuMeuRtjYE1caEBcff0sYEeW-90Kbeb-oWGHmB5P9cJ2_L1b17fhv" \
  --set falcosidekick.config.discord.minimumpriority="notice" \
  --set-file "customRules[0]"=<(cat <<EOF
- macro: argocd_pods
  condition: (k8s.ns.name = "argocd" and k8s.pod.name startswith "argocd-")

- rule: Modify Terminal Spawn for ArgoCD
  desc: Bo qua canh bao bat shell doi voi rieng cac Pod cua ArgoCD
  condition: spawned_process and proc.name = sh and argocd_pods
  output: "ArgoCD activity detected (ignored)"
  priority: INFO
  append: true
EOF
)

