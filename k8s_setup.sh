#!/bin/bash

eval $(minikube docker-env)

docker build -t my_app:local .

kubectl apply -f k8s/

kubectl rollout restart deployment my-app