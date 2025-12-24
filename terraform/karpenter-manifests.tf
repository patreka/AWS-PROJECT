resource "kubernetes_manifest" "ec2nodeclass" {
  count = var.apply_karpenter_manifests ? 1 : 0

  manifest = yamldecode(templatefile("${path.module}/k8s/ec2nodeclass.yaml.tpl", {
    cluster_name   = var.cluster_name
    node_role_name = aws_iam_role.karpenter_node.name
  }))

  depends_on = [helm_release.karpenter]
}

resource "kubernetes_manifest" "nodepool_amd64_spot" {
  count = var.apply_karpenter_manifests ? 1 : 0

  manifest   = yamldecode(templatefile("${path.module}/k8s/nodepool-amd64-spot.yaml.tpl", {}))
  depends_on = [kubernetes_manifest.ec2nodeclass]
}

resource "kubernetes_manifest" "nodepool_arm64_spot" {
  count = var.apply_karpenter_manifests ? 1 : 0

  manifest   = yamldecode(templatefile("${path.module}/k8s/nodepool-arm64-spot.yaml.tpl", {}))
  depends_on = [kubernetes_manifest.ec2nodeclass]
}
