terraform {
  required_version = ">= 1.3"
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.10.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.2"
    }
    kustomization = {
      source  = "kbst/kustomization"
      version = ">= 0.9.2"
    }
  }
}

locals {
  # https://github.blog/changelog/2022-01-18-githubs-ssh-host-keys-are-now-published-in-the-api/
  known_hosts = "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="

  bootstrap = try([for v in data.kubectl_file_documents.bootstrap[0].documents : {
    data : yamldecode(v)
    content : v
    }
  ], [])

  /*
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
  */
}

data "kustomization_build" "main" {
  path = var.kustomization_path
}

data "kubectl_file_documents" "bootstrap" {
  count   = var.bootstrap_manifest == null ? 0 : 1
  content = var.bootstrap_manifest
}

resource "kubectl_manifest" "bootstrap" {
  for_each           = { for v in local.bootstrap : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  override_namespace = var.namespace # TODO: A bit hacky, but we want a generic configmap (ca-certs) applied to various namespaces 
  # depends_on = [helm_release.argocd]
  yaml_body = each.value
}

# TODO: Should be replaced by kubectl (which uses apply and we need anyways )
/*
resource "kubernetes_namespace" "main" {
  count = var.namespace == null ? 1 : 0
  metadata {
    name = "flux-system"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
    ]
  }
}
*/

# first loop through resources in ids_prio[0]
resource "kustomization_resource" "p0" {
  for_each = data.kustomization_build.main.ids_prio[0]

  manifest = (
    contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
    ? sensitive(data.kustomization_build.main.manifests[each.value])
    : data.kustomization_build.main.manifests[each.value]
  )
}

# then loop through resources in ids_prio[1]
# and set an explicit depends_on on kustomization_resource.p0
# wait 2 minutes for any deployment or daemonset to become ready
resource "kustomization_resource" "p1" {
  for_each = data.kustomization_build.main.ids_prio[1]

  manifest = (
    contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
    ? sensitive(data.kustomization_build.main.manifests[each.value])
    : data.kustomization_build.main.manifests[each.value]
  )
  #wait = true
  #timeouts {
  #  create = "2m"
  #  update = "2m"
  #}

  depends_on = [kustomization_resource.p0]
}

# finally, loop through resources in ids_prio[2]
# and set an explicit depends_on on kustomization_resource.p1
resource "kustomization_resource" "p2" {
  for_each = data.kustomization_build.main.ids_prio[2]

  manifest = (
    contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
    ? sensitive(data.kustomization_build.main.manifests[each.value])
    : data.kustomization_build.main.manifests[each.value]
  )

  depends_on = [kustomization_resource.p1]
}

resource "kubernetes_secret" "main" {
  depends_on = [kustomization_resource.p0]
  count      = var.tls_key != null ? 1 : 0

  metadata {
    name      = "flux-system" # data.flux_sync.main.secret
    namespace = var.namespace # data.flux_sync.main.namespace
  }

  data = {
    # TODO: Name mapping - be careful with breaking changes downstream
    identity       = var.tls_key["private"] # tls_private_key.main.private_key_pem
    "identity.pub" = var.tls_key["public"]  # tls_private_key.main.public_key_pem
    known_hosts    = local.known_hosts
  }
}

resource "kubernetes_secret" "additional" {
  for_each   = var.additional_keys
  depends_on = [kustomization_resource.p0]

  metadata {
    name      = each.key
    namespace = var.namespace # "flux-system"
  }

  data = each.value
}
