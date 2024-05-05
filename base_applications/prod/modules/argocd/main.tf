resource "helm_release" "argocd_helm_release" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  version          = "6.7.3"
  chart            = "argo-cd"
  namespace        = "argocd"
  wait             = false
  cleanup_on_fail  = true
  create_namespace = true

  lifecycle {
    ignore_changes = [
      set
    ]
  }
}

