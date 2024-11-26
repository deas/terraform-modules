# https://github.com/hashicorp/terraform/issues/28580#issuecomment-831263879
# TODO: argocd namespace should be created here to be in alignment with flux module/kustomization provider
terraform {
  required_version = ">= 1.3"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.2"
    }
    kubectl = { # TODO : Should be replaced by kustomization provider to align with flux?
      source  = "alekc/kubectl"
      version = ">= 2.1.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0.0"
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
  #argocd_cluster = try([for v in data.kubectl_file_documents.argocd_cluster[0].documents : {
  #  data : yamldecode(v)
  #  content : v
  #  }
  #], [])
}

resource "kubectl_manifest" "bootstrap" {
  for_each   = { for v in local.bootstrap : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  depends_on = [kubernetes_namespace.argocd]
  yaml_body  = each.value
}


data "kubectl_file_documents" "bootstrap" {
  count   = var.bootstrap_path != null ? 1 : 0
  content = file(var.bootstrap_path)
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace
  }
}

# https://
/*
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
*/

# kubectl -n operators wait --for=jsonpath='{.status.state}'=AtLatestKnown subscription/argocd-operator
# https://github.com/hashicorp/terraform-provider-kubernetes/issues/1775
/*
resource "kubernetes_manifest" "subscription" {
  manifest = var.subscription
  wait {
    fields = { "status.state" = "AtLatestKnown" }
  }
}

resource "kubernetes_manifest" "argocd_instance" {
  manifest   = var.argocd_instance
  depends_on = [kubernetes_manifest.subscription]
}
*/

resource "kubectl_manifest" "subscription" {
  yaml_body = var.subscription.yaml_body
  wait_for {
    field {
      key   = "status.state"
      value = "AtLatestKnown"
    }
  }
}

resource "kubectl_manifest" "argocd_instance" {
  yaml_body  = var.argocd_instance
  depends_on = [kubectl_manifest.subscription]
  #wait_for { # TODO Does not work for initial creation - should report a bug and remove the null ressource below
  #  field {
  #    key   = "status.phase"
  #    value = "Available"
  #  }
  #}
}

# TODO: ns/name could be read from yaml
# TODO: Actually a workaround, because wait_for on argocd_instance only works on subsequent execution
resource "null_resource" "argocd_instance" {
  depends_on = [kubectl_manifest.argocd_instance]
  provisioner "local-exec" {
    command = "kubectl -n argocd wait --timeout 300s --for jsonpath='{.status.phase}'=Available argocd/argocd"
  }
}

resource "kubernetes_secret" "additional" {
  for_each = local.additional_keys

  metadata {
    name      = each.key
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }

  data = each.value
}

#data "kubectl_file_documents" "argocd_cluster" {
#  count   = var.cluster_manifest == null ? 0 : 1
#  content = var.cluster_manifest
#  # depends_on = [kubectl_manifest.argocd_instance]
#}

resource "kubectl_manifest" "argocd_cluster" {
  # for_each = { for v in local.argocd_cluster : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  # We should ensure the ArgoCD instance is up before we create the Application. Otherwise it takes quicte long to create up
  depends_on = [/* kubectl_manifest.argocd_instance,*/ null_resource.argocd_instance, kubernetes_namespace.argocd]
  yaml_body  = var.cluster_manifest # # each.value
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
