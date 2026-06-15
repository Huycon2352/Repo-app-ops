#!/bin/bash

#!/bin/bash




helm repo add grafana https://github.io
helm repo update

#helm upgrade --install loki grafana/loki -f loki-values-v2.yaml -n monitoring

helm upgrade --install loki-stack grafana/loki-stack \
  --create-namespace \
  --namespace logging \
  --set loki.enabled=true \
  --set promtail.enabled=true

