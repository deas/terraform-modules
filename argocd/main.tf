# https://github.com/hashicorp/terraform/issues/28580#issuecomment-831263879
# TODO: argocd namespace should be created here to be in alignment with flux module/kustomization provider
terraform {
  required_version = ">= 1.3"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.7.1"
    }
    kubectl = { # TODO : Should be replaced by kustomization provider to align with flux?
      source  = "alekc/kubectl"
      version = ">= 2.1.0"
    }
  }
}

locals {
  additional_keys = zipmap(
    keys(var.additional_keys),
    [for secret in values(var.additional_keys) :
      zipmap(
        keys(secret),
      [for path in values(secret) : file(path)])
  ])
  bootstrap = try([for v in data.kubectl_file_documents.bootstrap[0].documents : {
    data : yamldecode(v)
    content : v
    }
  ], {})
}

resource "kubectl_manifest" "bootstrap" {
  for_each   = { for v in local.bootstrap : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  depends_on = [kubernetes_namespace.argocd]
  yaml_body  = each.value
}


data "kubectl_file_documents" "bootstrap" {
  count   = var.bootstrap_path != null ? 1 : 0
  content = join("---\n", [for filename in var.bootstrap_path : file(filename)])
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace
  }
}

# https://www.arthurkoziel.com/setting-up-argocd-with-helm/
resource "helm_release" "this" {
  name             = var.release_name
  depends_on       = [kubernetes_secret.additional]
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.chart_version
  namespace        = kubernetes_namespace.argocd.metadata[0].name
  create_namespace = false # true
  values           = var.values
}

resource "kubernetes_secret" "additional" {
  for_each = local.additional_keys

  metadata {
    name      = each.key
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }

  data = each.value
}

locals {
  #argocd_operator = [for v in data.kubectl_file_documents.argocd_operator.documents : {
  #  data : yamldecode(v)
  #  content : v
  #  }
  #]
  argocd_cluster = try([for v in data.kubectl_file_documents.argocd_cluster[0].documents : {
    data : yamldecode(v)
    content : v
    }
  ], [])
}

data "kubectl_file_documents" "argocd_cluster" {
  count   = var.cluster_manifest == null ? 0 : 1
  content = var.cluster_manifest
}

resource "kubectl_manifest" "argocd_cluster" {
  for_each   = { for v in local.argocd_cluster : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  depends_on = [helm_release.this]
  yaml_body  = each.value
}

#resource "kubectl_manifest" "argocd_operator" {
#  for_each   = { for v in local.argocd_operator : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
#  depends_on = [kubectl_manifest.olm_crds]
#  yaml_body  = each.value
#  provisioner "local-exec" {
#    command = "while ! kubectl wait --for condition=established --timeout=60s crd/argocds.argoproj.io ; do sleep 3; done"
#    # works
#    # kubectl wait --for jsonpath='{.status.phase}'=Succeeded  --timeout=60s csvs/argocd-operator.v0.5.0 -n operators
#  }
#}

#resource "kubectl_manifest" "argocd" {
#  for_each   = { for v in local.argocd : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
#  yaml_body  = each.value
#  depends_on = [kubectl_manifest.argocd_operator]
#}
