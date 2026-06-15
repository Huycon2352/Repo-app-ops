#!/bin/bash

helm upgrade --install loki grafana/loki -f loki-values-v2.yaml -n monitoring
