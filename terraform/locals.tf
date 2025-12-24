data "aws_availability_zones" "available" {}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  common_tags = merge(var.tags, {
    Project                  = var.cluster_name
    "karpenter.sh/discovery" = var.cluster_name
  })

  # Graviton instance families შეიცავენ "g." (მაგ: m7g.large, c7g.large, t4g.medium)
  bootstrap_is_arm = can(regex("g\\.", var.bootstrap_instance_type))

  # EKS 1.33/1.34-ზე AL2 optimized AMI აღარ გამოდის => AL2023 გამოიყენე
  bootstrap_ami_type = local.bootstrap_is_arm ? "AL2023_ARM_64_STANDARD" : "AL2023_x86_64_STANDARD"
}
