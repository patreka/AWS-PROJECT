resource "kubernetes_service_account" "karpenter" {
  metadata {
    name      = "karpenter"
    namespace = "kube-system"

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.karpenter_controller.arn
    }
  }
}

resource "helm_release" "karpenter" {
  name      = "karpenter"
  namespace = "kube-system"

  # OCI chart (public ECR)
  chart   = "oci://public.ecr.aws/karpenter/karpenter"
  version = var.karpenter_version

  set {
    name  = "settings.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "settings.interruptionQueue"
    value = aws_sqs_queue.karpenter_interruption.name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.karpenter.metadata[0].name
  }

  # POC sizing similar to docs
  set {
    name  = "controller.resources.requests.cpu"
    value = "1"
  }

  set {
    name  = "controller.resources.requests.memory"
    value = "1Gi"
  }

  set {
    name  = "controller.resources.limits.cpu"
    value = "1"
  }

  set {
    name  = "controller.resources.limits.memory"
    value = "1Gi"
  }

  depends_on = [
    kubernetes_service_account.karpenter,
    aws_eks_access_entry.karpenter_nodes
  ]
}
