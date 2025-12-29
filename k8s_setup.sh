#!/bin/bash

eval $(minikube docker-env)

# Docker build command for Kubernetes deployment
docker build --no-cache -t my_app:local .
minikube image load my_app:local

# Apply Kubernetes manifests
kubectl apply -f k8s/


##
kubectl rollout restart deployment my-app