resource "helm_release" "ingress_nginx_helm_release" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  version          = "4.10.0"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  wait             = false
  cleanup_on_fail  = true
  create_namespace = true


  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }
  set {
    name  = "controller.autoscaling.enabled"
    value = "true"
  }
  set {
    name  = "controller.autoscaling.minReplicas"
    value = "3"
  }
  set {
    name  = "controller.service.internal.enabled"
    value = "true"
  }
  set {
    name  = "controller.service.internal.annotations.service\\.beta\\.kubernetes\\.io\\/azure-load-balancer-internal"
    value = "true"
  }

  set {
    name  = "controller.metrics.enabled"
    value = "true"
  }
  set {
    name  = "controller.metrics.serviceMonitor.enabled"
    value = true
  }

  set {
    name  = "controller.metrics.serviceMonitor.additionalLabels.release"
    value = "prometheus"
  }


  lifecycle {
    # create_before_destroy = true
    prevent_destroy = true
    # ignore_changes = all
  }
}