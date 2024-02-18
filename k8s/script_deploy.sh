#!/bin/bash

set -e

# get script's location
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

if [ -z "$KUBECONFIG" ]
then
    echo ${KUBERNETES_CA} | base64 --decode > udagram-ca.pem
    echo ${KUBERNETES_CLIENT_CA} | base64 --decode > udagram-client-ca.pem
    echo ${KUBERNETES_CLIENT_KEY} | base64 --decode > udagram-key.pem
    kubectl config set-cluster udagram --server=${KUBERNETES_ENDPOINT} --certificate-authority=udagram-ca.pem
    kubectl config set-credentials kubernetes-admin --client-certificate=udagram-client-ca.pem --client-key=udagram-key.pem
    kubectl config set-context kubernetes-admin@udagram --cluster=udagram --namespace=default --user=kubernetes-admin
    kubectl config use-context kubernetes-admin@udagram
fi

configmap=`envsubst '$JWT_SECRET $POSTGRES_USERNAME $POSTGRES_PASSWORD' < env-configmap.yml`
echo "configmap: $configmap" | kubectl apply -f -

secret=`envsubst '$JWT_SECRET $POSTGRES_USERNAME $POSTGRES_PASSWORD' < env-secret.yml`
echo "secret: $secret" | kubectl apply -f -

awsSecret=`envsubst '$AWS_CREDENTIALS' < aws-secret.yml`
echo "awsSecret: $awsSecret" | kubectl apply -f -

kubectl apply -f $DIR/deployment-api-feed.yml
kubectl apply -f $DIR/deployment-api-user.yml
kubectl apply -f $DIR/deployment-reverseproxy.yml
kubectl apply -f $DIR/deployment-frontend.yml
