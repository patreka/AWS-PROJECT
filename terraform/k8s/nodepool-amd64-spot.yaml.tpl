apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: amd64-spot
spec:
  template:
    metadata:
      labels:
        intent: apps
    spec:
      nodeClassRef:
        group: karpenter.k8s.aws
        kind: EC2NodeClass
        name: default
      requirements:
        - key: "kubernetes.io/arch"
          operator: In
          values: ["amd64"]
        - key: "kubernetes.io/os"
          operator: In
          values: ["linux"]
        - key: "karpenter.sh/capacity-type"
          operator: In
          values: ["spot"]
  limits:
    cpu: "200"
  disruption:
    consolidationPolicy: WhenEmptyOrUnderutilized
    consolidateAfter: 60s
