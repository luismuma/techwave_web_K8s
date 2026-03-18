#!/bin/bash
# setup-full.sh
# Script para borrar cluster, crear cluster con ArgoCD y desplegar app Flask
# Autor: Luis Muñoz
# Fecha: año 2026

set -e  # Salir si hay error
CLUSTER_NAME="argocd"
HELM_PATH="$HOME/proyecto_tokio/techwave_web_K8s/helm/flask-app"

echo "==========================================="
echo "🔥 Flujo completo: delete + create + deploy"
echo "Cluster: $CLUSTER_NAME"
echo "Helm chart: $HELM_PATH"
echo "==========================================="

# 1️⃣ Borrar cluster existente
echo "🗑  Borrando cluster existente (si existe)..."
if bash ./scripts/delete-kind.sh; then
    echo "✅ Cluster eliminado"
else
    echo "⚠ No existía cluster previo, seguimos..."
fi

# 2️⃣ Crear cluster + instalar ArgoCD
echo "🚀 Creando cluster '$CLUSTER_NAME' e instalando ArgoCD..."
bash ./scripts/install-argocd-kind_v2.sh "$CLUSTER_NAME"
echo "✅ Cluster creado y ArgoCD instalado"

# 3️⃣ Desplegar app Flask con Helm
echo "📦 Desplegando app Flask con Helm..."
helm upgrade --install flask-app "$HELM_PATH" -f "$HELM_PATH/values-green.yaml"
echo "✅ App Flask desplegada correctamente"

echo "==========================================="
echo "🎉 Flujo completo finalizado: Cluster listo con ArgoCD y app desplegada"
echo "==========================================="
