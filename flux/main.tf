# https://github.com/hashicorp/terraform/issues/28580#issuecomment-831263879
terraform {
  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
      // version = ">= 1.10.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      // version = ">= 2.0.2"
    }

  }
}

locals {
  known_hosts = "github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ=="

  install = [for v in data.kubectl_file_documents.install.documents : {
    data : yamldecode(v)
    content : v
    }
  ]
  sync = [for v in data.kubectl_file_documents.sync.documents : {
    data : yamldecode(v)
    content : v
    }
  ]
}

# TODO: Should be replaced by kubectl (which uses apply and we need anyways )
resource "kubernetes_namespace" "flux_system" {
  metadata {
    name = "flux-system"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
    ]
  }
}

data "kubectl_file_documents" "install" {
  content = var.flux_install # data.flux_install.main.content
}

data "kubectl_file_documents" "sync" {
  content = var.flux_sync # data.flux_sync.main.content
}


resource "kubectl_manifest" "install" {
  for_each   = { for v in local.install : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  depends_on = [kubernetes_namespace.flux_system]
  yaml_body  = each.value
}

resource "kubectl_manifest" "sync" {
  for_each   = { for v in local.sync : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  depends_on = [kubernetes_namespace.flux_system]
  yaml_body  = each.value
}

resource "kubernetes_secret" "main" {
  depends_on = [kubectl_manifest.install]

  metadata {
    name      = "flux-system" # data.flux_sync.main.secret
    namespace = "flux-system" # data.flux_sync.main.namespace
  }

  data = {
    identity       = var.tls_key["private"] # tls_private_key.main.private_key_pem
    "identity.pub" = var.tls_key["public"]  # tls_private_key.main.public_key_pem
    known_hosts    = local.known_hosts
  }
}

resource "kubernetes_secret" "additional" {
  for_each   = var.additional_keys
  depends_on = [kubectl_manifest.install]

  metadata {
    name      = each.key
    namespace = "flux-system"
  }

  data = each.value
}
