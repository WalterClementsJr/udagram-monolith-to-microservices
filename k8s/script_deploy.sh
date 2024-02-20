#!/bin/bash

set -e

cd ./k8s/

if [ -z "$KUBECONFIG" ]
then
    echo "kubectl config start"

#    echo ${KUBERNETES_CA} | base64 --decode > udagram-ca.pem
#    echo ${KUBERNETES_CLIENT_CA} | base64 --decode > udagram-client-ca.pem
#    echo ${KUBERNETES_CLIENT_KEY} | base64 --decode > udagram-key.pem
#    kubectl config set-cluster udagram --server=${KUBERNETES_ENDPOINT} --certificate-authority=udagram-ca.pem
#    kubectl config set-credentials kubernetes-admin --client-certificate=udagram-client-ca.pem --client-key=udagram-key.pem
#    kubectl config set-context kubernetes-admin@udagram --cluster=udagram --namespace=default --user=kubernetes-admin
#    kubectl config use-context kubernetes-admin@udagram

    echo "kubectl config completed"
fi

echo "kubectl apply steps start"

#awsSecret=$(envsubst '$AWS_CREDENTIALS' < aws-secret.yml)
#echo "done"
#echo "$awsSecret" | kubectl apply -f -

configmap=$(envsubst '$AWS_BUCKET $AWS_PROFILE $AWS_REGION $AWS_ACCESS_KEY_ID $AWS_SECRET_ACCESS_KEY $POSTGRES_HOST $POSTGRES_DB $URL' < env-configmap.yml)
echo "done"
echo "$configmap" | kubectl apply -f -

secret=$(envsubst '$JWT_SECRET $POSTGRES_USERNAME $POSTGRES_PASSWORD' < env-secret.yml)
echo "done"
echo "$secret" | kubectl apply -f -

echo "kubectl apply steps ok"

kubectl apply -f deployment-api-feed.yml
kubectl apply -f deployment-api-user.yml
kubectl apply -f deployment-reverseproxy.yml
kubectl apply -f deployment-frontend.yml
