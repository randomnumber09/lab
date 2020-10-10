# Lab Assignment

Produce necessary manifests to deploy a basic web application into any cloud providor.  Must have the following:
- A load balancer
- The software logic responsible for serving responding to HTTP requests
- A persistence backend


# Dependencies for this lab

AWS cli - configure cli [AWS CLI](https://aws.amazon.com/cli/)

Terraform - This lab was built with Terraform v0.13.4 [Terraform](https://www.terraform.io/)

kubectl - This lab was built with v1.19.2 [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

## What does this do

- This lab uses Terraform to create a AWS VPC, internet gateway, routing table, security groups, and subnets.
- This lab uses Terraform to create a Kubernetes Cluster on AWS Elastick Kubernetes Service utilizing deployments, secrets, and services.
-  This lab creates a mySql RDS instance for data persistency utilizing Terraform's aws_db_instance.
- An AWS load balancer is created utilizing Terraform's kubernetes_service.
- I built a extreamly simple ruby on rails application | rails g scaffold post name comment:text | dockerized it and pushed it to dockerhub. https://github.com/randomnumber09/rorhelloworld



## Usage
Install dependencies, configure AWS cli and Export 4 variables with terraform's environment variable convention TF_VAR_ENVIRONMENT_VARIABLE
```bash
export TF_VAR_AWS_ACCESS_KEY_ID=
export TF_VAR_AWS_SECRET_ACCESS_KEY=
export TF_VAR_DB_USER=
export TF_VAR_DB_PASSWORD=

terraform init
terraform apply
```

After running terraform, your application will output a url of the load balancer.  Add /posts to the end of the url to access the application.

Example:  http://a31aad721709c48009225b62009ab6d4-383473222.us-east-1.elb.amazonaws.com/posts
```bash
Apply complete! Resources: 37 added, 0 changed, 0 destroyed.

Outputs:

lb_ip2 = a31aad721709c48009225b62009ab6d4-383473222.us-east-1.elb.amazonaws.com
```

You can interact with your kubernetes cluster by typing the following:

```bash
aws eks --region us-east-1 update-kubeconfig --name labcluster
kubectl commands

```

# Cleanup
```bash
terraform destroy
```
