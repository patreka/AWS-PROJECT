variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
  default     = "eks-kp-poc"
}

variable "kubernetes_version" {
  type        = string
  description = "EKS Kubernetes version (use the latest currently supported in your org)"
  default     = "1.34"
}

variable "karpenter_version" {
  type        = string
  description = "Karpenter Helm chart version"
  default     = "1.8.3"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR"
  default     = "10.0.0.0/16"
}

variable "az_count" {
  type        = number
  description = "How many AZs to use"
  default     = 3
}

variable "bootstrap_instance_type" {
  type        = string
  description = "Bootstrap managed node group instance type"
  default     = "m5.large"
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to resources"
  default     = {}
}
variable "apply_karpenter_manifests" {
  type        = bool
  description = "Apply Karpenter EC2NodeClass/NodePools after cluster is reachable"
  default     = false
}
