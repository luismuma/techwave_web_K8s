#!/bin/bash

set -e

echo "🔥 PASO 1 — Limpieza rápida"
kubectl delete namespace argocd --wait --ignore-not-found

echo "⏳ Esperando que el namespace se elimine completamente..."
sleep 5

echo "🔧 PASO 2 — Instalar ArgoCD"
kubectl create namespace argocd

kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "⏳ Esperando que los pods se creen..."
sleep 60

echo "🛠️ PASO 3 — Eliminar SOLO el ApplicationSet"
kubectl delete deploy argocd-applicationset-controller -n argocd --ignore-not-found
kubectl delete svc argocd-applicationset-controller -n argocd --ignore-not-found
kubectl delete clusterrole argocd-applicationset-controller --ignore-not-found
kubectl delete clusterrolebinding argocd-applicationset-controller --ignore-not-found

echo "⏳ Esperando que ArgoCD estabilice..."
sleep 15

echo "✅ PASO 4 — Verificar pods"
kubectl get pods -n argocd

echo ""
echo "🚀 PASO 5 — Acceso a la UI"
echo "Ejecuta en otra terminal:"
echo ""
echo "kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo ""
echo "Luego abre:"
echo "👉 https://localhost:8080"
echo ""
echo "Usuario: admin"
echo "Password:"
echo "kubectl -n argocd get secret argocd-initial-admin-secret \\"
echo "  -o jsonpath=\"{.data.password}\" | base64 -d"
echo ""
echo "🎉 Instalación completada."
