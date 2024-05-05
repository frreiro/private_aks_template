locals {
  namespace = "kube-prometheus-stack"
}
resource "kubernetes_namespace" "prometheus" {
  metadata {
    name = local.namespace
  }
}


resource "helm_release" "kube_prometheus" {
  name             = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  version          = "58.0.0"
  chart            = "kube-prometheus-stack"
  namespace        = local.namespace
  wait             = false
  cleanup_on_fail  = true
  create_namespace = true

  set {
    name  = "prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues"
    value = "false"
  }

 set {
    name  = "prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues"
    value = "false"
  }

  set {
    name  = "grafana.sidecar.dashboards.provider.allowUiUpdates"
    value = "true"
  }

  set {
    name  = "grafana.sidecar.dashboards.annotations.k8s-sidecar-target-directory"
    value = "/tmp/dashboards/kubernetes"
  }

  depends_on = [
    # kubernetes_manifest.external_secret_credentials
  ]

}




resource "kubernetes_config_map" "grafana_custom_dashboard" {
  metadata {
    name      = "grafana-dashboard-custom"
    namespace = "kube-prometheus-stack"

    labels = {
      grafana_dashboard = 1
    }

    annotations = {
      k8s-sidecar-target-directory = "/tmp/dashboards/custom"
    }
  }

  data = {
    "nginx.json" = file("${path.module}/custom_dashboards/nginx.json"),
    "cert_manager.json" = file("${path.module}/custom_dashboards/cert_manager.json"),
  }
}

