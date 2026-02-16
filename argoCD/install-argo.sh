#!/bin/bash
set -e

echo "🔧 1. Verificando dependencias..."
command -v docker >/dev/null || { echo "❌ Docker no instalado"; exit 1; }
command -v kind >/dev/null || { echo "❌ kind no instalado"; exit 1; }
command -v kubectl >/dev/null || { echo "❌ kubectl no instalado"; exit 1; }

echo "✅ Dependencias OK"

echo "🐳 2. Creando cluster kind para ArgoCD..."
kind create cluster --name argocd

echo "📦 3. Creando namespace argocd..."
kubectl create namespace argocd || true

echo "🚀 4. Instalando ArgoCD (manifiesto oficial estable)..."
kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "⏳ 5. Esperando a que ArgoCD arranque..."
kubectl wait --for=condition=Available deployment/argocd-server \
  -n argocd --timeout=300s

echo "🔐 6. Obteniendo password inicial..."
PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d)

echo ""
echo "🎉 ArgoCD listo!"
echo "👉 Usuario: admin"
echo "👉 Password: $PASSWORD"
echo ""
echo "🌐 Ejecuta en otra terminal:"
echo "kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "Luego abre: https://localhost:8080"
