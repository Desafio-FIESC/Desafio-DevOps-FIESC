#!/bin/bash

TAG=$(date +%Y%m%d%H%M%S)
BACKEND_IMAGE="hermaniosan124/backend:$TAG"
FRONTEND_IMAGE="hermaniosan124/frontend:$TAG"

echo "🔧 Buildando imagens..."
docker build -t $BACKEND_IMAGE ./backend
docker build -t $FRONTEND_IMAGE ./frontend

echo "📤 Enviando para Docker Hub..."
docker push $BACKEND_IMAGE
docker push $FRONTEND_IMAGE

echo "🔁 Atualizando Deployments no Kubernetes..."
kubectl set image deployment/backend backend=$BACKEND_IMAGE
kubectl set image deployment/frontend frontend=$FRONTEND_IMAGE

echo "✅ Deploy finalizado com sucesso!"
