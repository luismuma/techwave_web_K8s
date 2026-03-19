#!/bin/bash
# setup-full.sh
# Script para borrar cluster, crear cluster con ArgoCD y desplegar app Flask
# Autor: Luis Muñoz
# Fecha: año 2026

set -euo pipefail  # Salir si hay error o variable no definida
CLUSTER_NAME="${1:-argocd}"   # Permite pasar nombre de cluster como argumento
HELM_PATH="$HOME/proyecto_tokio/techwave_web_K8s/helm/flask-app"
NAMESPACE="${2:-flask-app}"    # Namespace opcional

# Obtener ruta del script actual
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==========================================="
echo "🔥 Flujo completo: delete + create + deploy"
echo "Cluster: $CLUSTER_NAME"
echo "Helm chart: $HELM_PATH"
echo "Namespace: $NAMESPACE"
echo "==========================================="

# 1️⃣ Borrar cluster existente
echo "🗑  Borrando cluster existente (si existe)..."
if [[ -f "$SCRIPT_DIR/delete-kind.sh" ]]; then
    bash "$SCRIPT_DIR/delete-kind.sh"
    echo "✅ Cluster eliminado"
else
    echo "⚠ Script delete-kind.sh no encontrado, saltando paso..."
fi

# 2️⃣ Crear cluster + instalar ArgoCD
echo "🚀 Creando cluster '$CLUSTER_NAME' e instalando ArgoCD..."
if [[ -f "$SCRIPT_DIR/install-argocd-kind_v2.sh" ]]; then
    bash "$SCRIPT_DIR/install-argocd-kind_v2.sh" "$CLUSTER_NAME"
    echo "✅ Cluster creado y ArgoCD instalado"
else
    echo "❌ Script install-argocd-kind_v2.sh no encontrado, abortando"
    exit 1
fi

# 3️⃣ Desplegar app Flask con Helm
echo "📦 Desplegando app Flask con Helm..."
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
helm upgrade --install flask-app "$HELM_PATH" \
    -f "$HELM_PATH/values-green.yaml" \
    --namespace "$NAMESPACE"
echo "✅ App Flask desplegada correctamente"

echo "==========================================="
echo "🎉 Flujo completo finalizado: Cluster listo con ArgoCD y app desplegada"
echo "==========================================="
