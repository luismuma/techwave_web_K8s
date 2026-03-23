#!/bin/bash
# install-argocd.sh
# Instala ArgoCD en un cluster Kind ya existente

set -euo pipefail

NAMESPACE="argocd"

echo "==========================================="
echo "📦 Instalando ArgoCD en namespace: $NAMESPACE"
echo "==========================================="

# Crear namespace si no existe
kubectl get ns "$NAMESPACE" >/dev/null 2>&1 || kubectl create namespace "$NAMESPACE"

# Instalar ArgoCD sin validación (más estable en CI)
kubectl apply --validate=false -n "$NAMESPACE" \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "⏳ Esperando a que los pods de ArgoCD estén listos..."
kubectl wait --for=condition=Ready pods --all -n "$NAMESPACE" --timeout=180s

echo "🎉 ArgoCD instalado correctamente."
echo "Puedes acceder al estado con:"
echo "kubectl get pods -n $NAMESPACE"
