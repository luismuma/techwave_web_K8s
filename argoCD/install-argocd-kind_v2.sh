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
# 2️⃣ Instalar kind si no existe
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
# 3️⃣ Crear config Kind con mapeo de puertos
############################
echo "⚙️ Generando configuración kind..."

cat <<EOF > kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    extraPortMappings:
      - containerPort: 30007
        hostPort: 30007
        protocol: TCP
      - containerPort: 30903
        hostPort: 9093
        protocol: TCP
EOF

############################
# 4️⃣ Crear cluster kind
############################
if kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
  echo "ℹ️ El cluster kind '$CLUSTER_NAME' ya existe"
  echo "⚠️ Si necesitas recrearlo con port mappings:"
  echo "kind delete cluster --name $CLUSTER_NAME"
else
  echo "🚀 Creando cluster kind '$CLUSTER_NAME'..."
  kind create cluster --name "$CLUSTER_NAME" --config kind-config.yaml
fi

############################
# 5️⃣ Usar contexto correcto
############################
kubectl config use-context kind-$CLUSTER_NAME

############################
# 6️⃣ Crear namespace ArgoCD
############################
kubectl create namespace $ARGO_NS 2>/dev/null || true

############################
# 7️⃣ Instalar ArgoCD
############################
echo "📦 Instalando ArgoCD..."
kubectl apply -n $ARGO_NS \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

############################
# 8️⃣ Esperar a ArgoCD
############################
echo "⏳ Esperando a que ArgoCD esté listo..."
kubectl wait \
  --for=condition=Available \
  deployment/argocd-server \
  -n $ARGO_NS \
  --timeout=300s

############################
# 9️⃣ Exponer ArgoCD en NodePort 30903
############################
echo "🌐 Exponiendo ArgoCD en puerto 9093..."

kubectl patch svc argocd-server -n $ARGO_NS \
  -p '{"spec":{"type":"NodePort","ports":[{"port":443,"targetPort":8080,"nodePort":30903}]}}'

############################
# 🔟 Mostrar pods
############################
echo "📊 Pods de ArgoCD:"
kubectl get pods -n $ARGO_NS

############################
# 1️⃣1️⃣ Mostrar password admin
############################
echo "🔐 Password inicial (admin):"
kubectl -n $ARGO_NS get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
echo

############################
# 1️⃣2️⃣ Instrucciones finales
############################
echo "======================================"
echo "🌐 Acceso a ArgoCD UI"
echo "======================================"
echo "URL: https://localhost:9093"
echo "Usuario: admin"
echo "======================================"
echo "✅ ArgoCD listo para usar"
