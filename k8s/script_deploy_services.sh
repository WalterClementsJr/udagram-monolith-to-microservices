kubectl apply -f ./service-api-feed.yml
kubectl apply -f ./service-api-user.yml
kubectl apply -f ./service-reverseproxy.yml
kubectl apply -f ./service-frontend.yml

# metrics monitoring
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
