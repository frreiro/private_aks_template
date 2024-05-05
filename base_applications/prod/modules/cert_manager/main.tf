resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  version          = "1.14.4"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  wait             = false
  cleanup_on_fail  = true
  create_namespace = true

  set {
    name  = "installCRDs"
    value = true
  }

  set {
    name  = "ReplicaCount"
    value = "3"
  }

  # set {
  #   name  = "prometheus"
  #   value = true
  # }

  # set {
  #   name  = "prometheus.servicemonitor.enabled"
  #   value = true
  # }


  lifecycle {
    ignore_changes = [
      set
    ]
  }
}

resource "kubernetes_manifest" "cluster_issuer" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name" = "letsencrypt-production"
    }
    "spec" = {
      "acme" = {
        "server" = "https://acme-v02.api.letsencrypt.org/directory"
        "email"  = "alpha@ezops.cloud"
        "privateKeySecretRef" = {
          "name" = "ezops-secret"
        }
        "solvers" = [{
          "http01" = {
            "ingress" = {
              "ingressClassName" = "nginx"
            }
          }
          }
        ]
      }
    }
  }
  depends_on = [helm_release.cert_manager]
}


resource "kubernetes_manifest" "cluster_issuer_staging" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name" = "letsencrypt-staging"
    }
    "spec" = {
      "acme" = {
        "server" = "https://acme-staging-v02.api.letsencrypt.org/directory"
        "email"  = "alpha@ezops.cloud"
        "privateKeySecretRef" = {
          "name" = "ezops-secret-staging"
        }
        "solvers" = [{
          "http01" = {
            "ingress" = {
              "ingressClassName" = "nginx"
            }
          }
          }
        ]
      }
    }
  }
  depends_on = [helm_release.cert_manager]
}

# resource "kubernetes_manifest" "cluster_issuer_staging_azure" {
#   manifest = {
#     "apiVersion" = "cert-manager.io/v1"
#     "kind"       = "ClusterIssuer"
#     "metadata" = {
#       "name" = "letsencrypt-staging-azure"
#     }
#     "spec" = {
#       "acme" = {
#         "server" = "https://acme-staging-v02.api.letsencrypt.org/directory"
#         "email"  = "alpha@ezops.cloud"
#         "privateKeySecretRef" = {
#           "name" = "ezops-secret-staging"
#         }
#         "solvers" = [{
#           "dns01" = {
#             "azureDNS" = {
#               "clientID" = "nginx"
#             }
#           }
#           }
#         ]
#       }
#     }
#   }
#   depends_on = [helm_release.cert_manager]
# }
