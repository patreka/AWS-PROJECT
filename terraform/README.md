# EKS + Karpenter POC (Terraform)

This repository provisions an Amazon EKS cluster and supporting AWS infrastructure using Terraform.  
It also installs Karpenter via Helm and (optionally) applies Karpenter manifests (EC2NodeClass + NodePools).

## What this creates

- **VPC** with public and private subnets across multiple AZs
- **NAT Gateway** (single NAT for the POC)
- **EKS cluster** (version configurable)
- **EKS managed node group** named **bootstrap** (used to bring the cluster online)
- **EKS addons** (installed by the EKS module):
  - `vpc-cni` (installed before compute)
  - `coredns`
  - `kube-proxy`
  - `eks-pod-identity-agent` (installed before compute)
- **Karpenter**:
  - IRSA service account (`kube-system/karpenter`)
  - Controller IAM role + policy
  - Node IAM role (for instances Karpenter launches)
  - SQS interruption queue + EventBridge rules
  - Optional Kubernetes manifests (EC2NodeClass + NodePools)

---

## Requirements

- Terraform `>= 1.5`
- AWS CLI installed
- `kubectl` installed
- Internet access to AWS endpoints

---

## AWS Credentials (Local setup)

This project assumes you have AWS credentials configured locally using the AWS CLI.

1) Configure credentials:
```bash
aws configure


> If your account never used Spot, you may need:
> `aws iam create-service-linked-role --aws-service-name spot.amazonaws.com || true`

## Deploy
```bash
terraform init
terraform apply
## Kubernetes manifests in `k8s/` (what to run after Terraform)

Your `k8s/` folder contains:

- `ec2nodeclass.yaml.tpl` (template)
- `nodepool-amd64-spot.yaml.tpl` (template)
- `nodepool-arm64-spot.yaml.tpl` (template)
- `demo-amd64.yaml` (demo workload)
- `demo-arm64.yaml` (demo workload)

### Step 1 — Connect kubectl to the EKS cluster

```bash
aws eks update-kubeconfig --region <REGION> --name <CLUSTER_NAME>
kubectl get ns
kubectl -n kube-system get deploy karpenter
kubectl -n kube-system get pods | grep karpenter
kubectl -n kube-system logs deploy/karpenter -f
