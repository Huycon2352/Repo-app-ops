#!/bin/bash

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Update repositories
helm repo update

# Create monitoring namespace
kubectl create namespace monitoring

# Install with default values
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace
  
 # Tuy chinh lai alerting thong qua discord, cau hinh alerting
 #helm upgrade prometheus prometheus-community/kube-prometheus-stack \
 # --namespace monitoring \
 # -f values-alerting.yaml
 
 #helm upgrade prometheus prometheus-community/kube-prometheus-stack \
 # --namespace monitoring \
 # -f values-prometheus.yaml
 
 # Cau hinh tao Alerting dua tren tracking pod hoatdong
 #helm upgrade prometheus prometheus-community/kube-prometheus-stack \
 # --namespace monitoring \
 # -f values-custom-alerts.yaml
