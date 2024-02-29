# project

## setup
- node 14
- `kubeone` to create k8s cluster
- `kubectl`
- TravisCI account
- Dockerhub

### 1. s3 bucket

create s3 bucket with

permission:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1625306057759",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::walker-udagram-bucket"
        }
    ]
}
```

CORS:

```json
[
    {
        "AllowedHeaders": [
            "*"
        ],
        "AllowedMethods": [
            "GET",
            "PUT",
            "POST",
            "DELETE"
        ],
        "AllowedOrigins": [
            "*"
        ],
        "ExposeHeaders": [],
        "MaxAgeSeconds": 3000
    }
]
```

### 2. database

create a PostgreSQL instance on AWS RDS (15.x).

create `udagram` database.

### 3. TravisCI

add the environment variables `DOCKER_PASSWORD`, `DOCKER_USERNAME`

## execution

```shell
# build and push docker images


# create k8s infra
# edit .tfvars file
cd terraform
terraform apply -var-file .tfvars --auto-approve
terraform output -json > tf.json

# create a keypair on AWS
ssh-keygen -y -f mykey.pem > mykey.pub
eval `ssh-agent -s`
ssh-add ~/.ssh/udagram.pem

# create the k8s cluster
kubeone apply --tfjson tf.json -y
cp udagram-kubeconfig ~/.kube/config 
# or KUBECONFIG=$PWD/udagram-kubeconfig

# deploy service
cd ../k8s/
./script_deploy_services.sh
kubectl get svc

# edit env variables, check the env variables used in env-secret.yml and env-configmap.yml

./script_deploy.sh
# then update frontend reverseproxy url in environment.prod.ts

# update docker containers
cd ../docker
docker compose -f docker-compose-build.yml build --parallel
docker compose -f docker-compose-build.yml push

# check deployments
kubectl get pods
kubectl logs [pod_name]
kubectl exec [pod_name] -- [command]
# horizontal scaling
kubectl autoscale deployment frontend --cpu-percent=50 --min=1 --max=2
kubectl get hpa
kubectl delete hpa [hpa_name]

# fixing & redeploying
kubectl delete deployment [deployment name]
kubectl delete --all deployments


# destroy k8s cluster & infra
kubeone reset --tfjson tf.json -y
terraform destroy -var-file .tfvars --auto-approve

# then manually delete 2 load balancers on AWS Console
```

# improvements

- provision EKS cluster using `terraform`
