
# https://github.com/hashicorp/terraform/issues/28580#issuecomment-831263879
terraform {
  required_version = ">= 1.3"
  required_providers {
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.1.0"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.2.0"
    }
    #kustomization = {
    #  source  = "kbst/kustomization"
    #  version = ">= 0.9.6"
    #}
  }
}

#data "kustomization_build" "main" {
#  path = var.kustomization_path
#}

# first loop through resources in ids_prio[0]
#resource "kustomization_resource" "p0" {
#  for_each = data.kustomization_build.main.ids_prio[0]
#
#  manifest = (
#    contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
#    ? sensitive(data.kustomization_build.main.manifests[each.value])
#    : data.kustomization_build.main.manifests[each.value]
#  )
#}

# then loop through resources in ids_prio[1]
# and set an explicit depends_on on kustomization_resource.p0
# wait 2 minutes for any deployment or daemonset to become ready
#resource "kustomization_resource" "p1" {
#  for_each = data.kustomization_build.main.ids_prio[1]
#
#  manifest = (
#    contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
#    ? sensitive(data.kustomization_build.main.manifests[each.value])
#    : data.kustomization_build.main.manifests[each.value]
#  )
#  #wait = true
#  #timeouts {
#  #  create = "2m"
#  #  update = "2m"
#  #}
#
#  depends_on = [kustomization_resource.p0]
#}

# finally, loop through resources in ids_prio[2]
# and set an explicit depends_on on kustomization_resource.p1
#resource "kustomization_resource" "p2" {
#  for_each = data.kustomization_build.main.ids_prio[2]
#
#  manifest = (
#    contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
#    ? sensitive(data.kustomization_build.main.manifests[each.value])
#    : data.kustomization_build.main.manifests[each.value]
#  )
#
#  depends_on = [kustomization_resource.p1]
# }

data "http" "olm_crds" {
  url = var.url_olm_crds
  # Optional request headers
  # request_headers = {
  #  Accept = "application/json"
  #}
}
# data.http.olm_crd.response_body # status_code

data "http" "olm" {
  url = var.url_olm
}

locals {
  olm_crds = [for v in data.kubectl_file_documents.olm_crds.documents : {
    data : yamldecode(v)
    content : v
    }
  ]
  olm = [for v in data.kubectl_file_documents.olm.documents : {
    data : yamldecode(v)
    content : v
    }
  ]
}

# TODO: olm should probably be kicked off via argocd
data "kubectl_file_documents" "olm_crds" {
  content = data.http.olm_crds.response_body
}

data "kubectl_file_documents" "olm" {
  content = data.http.olm.response_body
}

resource "kubectl_manifest" "olm_crds" {
  for_each = { for v in local.olm_crds : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  server_side_apply = true # Needed to prevent last-applied annotation to blow up b/c of size
  yaml_body         = each.value
}

resource "kubectl_manifest" "olm" {
  for_each   = { for v in local.olm : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  depends_on = [kubectl_manifest.olm_crds]
  yaml_body  = each.value
}

