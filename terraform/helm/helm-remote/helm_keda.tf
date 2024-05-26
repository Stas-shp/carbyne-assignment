resource "helm_release" "keda" {
  name             = "keda"
  namespace        = "keda" #kubernetes_namespace.keda-namespace.metadata.0.name
  repository       = "https://kedacore.github.io/charts"
  chart            = "keda"
  version          = "2.14.1"
  create_namespace = true
}
