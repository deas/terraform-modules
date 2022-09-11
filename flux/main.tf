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
  # https://github.blog/changelog/2022-01-18-githubs-ssh-host-keys-are-now-published-in-the-api/
  known_hosts = "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="

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
