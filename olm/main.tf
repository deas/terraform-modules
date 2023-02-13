
# https://github.com/hashicorp/terraform/issues/28580#issuecomment-831263879
terraform {
  required_version = ">= 1.3"
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.10.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.2.0"
    }
  }
}


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
  for_each  = { for v in local.olm_crds : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  yaml_body = each.value
}

resource "kubectl_manifest" "olm" {
  for_each   = { for v in local.olm : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  depends_on = [kubectl_manifest.olm_crds]
  yaml_body  = each.value
}