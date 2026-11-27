# E-commerce EKS Terraform Starter

Terraform starter for the E-commerce microservices learning project.

## Included

- AWS VPC in Mumbai (`ap-south-1`) with public/private subnets in two AZs
- Single NAT Gateway (cost-saving option; still incurs ongoing charges)
- EKS cluster with managed node group
- Seven ECR repositories
- Private shared PostgreSQL RDS instance
- ElastiCache Redis for the cart service
- Generated PostgreSQL admin password stored in AWS Secrets Manager

## Important architecture notes

1. The PostgreSQL instance is shared infrastructure. This starter creates one PostgreSQL database (`ecommerce`) and one admin credential. Before application rollout, create separate logical databases and separate least-privilege users for user, product, order, payment and inventory services. Do not give application services the admin credential.
2. Redis is provisioned for the cart service.
3. Notification's MongoDB-compatible persistence is not provisioned in this starter. Decide between Amazon DocumentDB and self-managed MongoDB after reviewing cost and compatibility. DocumentDB can be expensive for a learning environment.
4. The starter does not yet install Argo CD, AWS Load Balancer Controller, External Secrets, Prometheus or Grafana. Those are later deployment phases.
5. EKS, NAT Gateway, RDS and ElastiCache incur charges while provisioned. Review the plan and AWS pricing before applying.
6. EKS public API endpoint is enabled for initial learning access. Restrict `cluster_endpoint_public_access_cidrs` to your public IP before applying in a real environment.
7. Terraform state contains sensitive values, including the generated database password. Do not commit state files. Configure encrypted remote state and locking before using this beyond a disposable lab. For this first bootstrap, local state is used; protect the working directory.

## Prerequisites

- Terraform >= 1.6
- AWS CLI v2
- An AWS CLI profile named `ecommerce-dev`
- IAM permissions to create the listed VPC, EKS, ECR, RDS, ElastiCache, Secrets Manager and IAM resources

Configure the profile:

```powershell
aws configure --profile ecommerce-dev
aws sts get-caller-identity --profile ecommerce-dev
```

## Setup

Copy the example variables file:

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
```

Review `terraform.tfvars` and update settings, especially the EKS public endpoint CIDR setting in `main.tf` before applying.

Initialize:

```powershell
terraform init
```

Format and validate:

```powershell
terraform fmt -recursive
terraform validate
```

Review the plan:

```powershell
terraform plan -out ecommerce-dev.tfplan
```

Only if you understand and approve every resource and cost:

```powershell
terraform apply ecommerce-dev.tfplan
```

Configure kubectl:

```powershell
aws eks update-kubeconfig --region ap-south-1 --name ecommerce-dev-eks --profile ecommerce-dev
kubectl get nodes
```

## Destroy

Destroying deletes infrastructure and may permanently delete data. For this learning environment:

```powershell
terraform plan -destroy
```

Review the plan carefully before running `terraform destroy`.

## Known limitations to address in the next phase

- Replace local Terraform state with an encrypted S3 backend and state locking.
- Restrict EKS API access to trusted IP ranges or use private access.
- Create separate PostgreSQL databases and service-specific users/permissions.
- Store service credentials in Secrets Manager and expose them to pods through a secure integration.
- Add DocumentDB only after cost review.
- Add backup retention, deletion protection and production-grade network/security settings before production use.
- Confirm that the selected EKS Kubernetes version and instance classes are available in the target region when applying.
