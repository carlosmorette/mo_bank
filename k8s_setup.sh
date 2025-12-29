#!/bin/bash

eval $(minikube docker-env)

docker build --no-cache -t my_app:local .

kubectl rollout restart deployment my-app