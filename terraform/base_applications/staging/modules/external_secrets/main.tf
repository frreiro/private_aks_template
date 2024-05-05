resource "helm_release" "external_secret_helm_release" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io/"
  version          = "0.9.14"
  chart            = "external-secrets"
  namespace        = "external-secrets"
  wait             = false
  cleanup_on_fail  = true
  create_namespace = true

  lifecycle {
    prevent_destroy = true
    ignore_changes  = all
  }
}

resource "kubernetes_namespace" "credentials" {
  metadata {
    name = "credentials"
  }

  depends_on = [helm_release.external_secret_helm_release]
}

resource "kubernetes_manifest" "service_principal_credentials" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "Secret"
    "metadata" = {
      "name"      = "azure-secret-service-principal"
      "namespace" = "credentials"
    }
    "type" = "Opaque"
    "data" = {
      "ClientID"     = base64encode(var.client_id)
      "ClientSecret" = base64encode(var.client_secret)

    }
  }
  depends_on = [kubernetes_namespace.credentials]
}


resource "kubernetes_manifest" "cluster_secret_store" {
  manifest = {
    "apiVersion" = "external-secrets.io/v1alpha1"
    "kind"       = "ClusterSecretStore"
    "metadata" = {
      "name" = "cluster-secret-store"
    }
    "spec" = {
      "provider" = {
        "azurekv" = {
          "tenantId" = "${var.tenant_id}"
          "vaultUrl" = "https://${lower(var.vault_config_name)}.vault.azure.net"
          "authSecretRef" = {
            "clientId" = {
              "name"      = "azure-secret-service-principal"
              "key"       = "ClientID"
              "namespace" = "credentials"
            }
            "clientSecret" = {
              "name"      = "azure-secret-service-principal"
              "key"       = "ClientSecret"
              "namespace" = "credentials"
            }
          }
        }
      }
    }
  }
  depends_on = [kubernetes_manifest.service_principal_credentials]
}
