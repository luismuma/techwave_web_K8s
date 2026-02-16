#!/bin/bash
set -e

CLUSTER_NAME="argocd"
ARGO_NS="argocd"

echo "======================================"
echo "🟢 Instalación ArgoCD en kind (LOCAL)"
echo "======================================"

############################
# 1️⃣ Comprobar dependencias
############################
echo "🔎 Comprobando dependencias..."

for cmd in docker kubectl curl; do
  if ! command -v $cmd &>/dev/null; then
    echo "❌ Falta $cmd. Instálalo antes de continuar."
    exit 1
  fi
done

############################
# 2️⃣ Instalar kind
############################
if ! command -v kind &>/dev/null; then
  echo "⬇️ Instalando kind..."
  curl -Lo kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-amd64
  chmod +x kind
  sudo mv kind /usr/local/bin/kind
else
  echo "✅ kind ya instalado"
fi

############################
# 3️⃣ Crear cluster kind
############################
if kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
  echo "ℹ️ El cluster kind '$CLUSTER_NAME' ya existe"
else
  echo "🚀 Creando cluster kind '$CLUSTER_NAME'..."
  kind create cluster --name "$CLUSTER_NAME"
fi

############################
# 4️⃣ Usar contexto correcto
############################
kubectl config use-context kind-$CLUSTER_NAME

############################
# 5️⃣ Crear namespace ArgoCD
############################
kubectl create namespace $ARGO_NS 2>/dev/null || true

############################
# 6️⃣ Instalar ArgoCD
############################
echo "📦 Instalando ArgoCD..."
kubectl apply -n $ARGO_NS \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

############################
# 7️⃣ Esperar a ArgoCD
############################
echo "⏳ Esperando a que ArgoCD esté listo..."
kubectl wait \
  --for=condition=Available \
  deployment/argocd-server \
  -n $ARGO_NS \
  --timeout=300s

############################
# 8️⃣ Mostrar pods
############################
echo "📊 Pods de ArgoCD:"
kubectl get pods -n $ARGO_NS

############################
# 9️⃣ Mostrar password admin
############################
echo "🔐 Password inicial (admin):"
kubectl -n $ARGO_NS get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
echo

############################
# 🔟 Instrucciones de acceso
############################
echo "======================================"
echo "🌐 Acceso a ArgoCD UI"
echo "======================================"
echo "kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo
echo "URL: https://localhost:8080"
echo "Usuario: admin"
echo "======================================"
echo "✅ ArgoCD listo para usar"
