# https://github.com/hashicorp/terraform/issues/28580#issuecomment-831263879
terraform {
  required_version = ">= 1.2.0"

  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.1.0"
    }
  }
}

locals {
  metallb_native = [
    for v in data.kubectl_file_documents.metallb_native.documents : {
      data : yamldecode(v)
      content : v
    }
  ]
  metallb_config = try([
    for v in data.kubectl_file_documents.metallb_config[0].documents : {
      data : yamldecode(v)
      content : v
    }
  ], [])
}

# TODO: metallb could probably be kicked off via flux/argo as well
data "kubectl_file_documents" "metallb_native" {
  content = var.install_manifest
}

resource "kubectl_manifest" "metallb_native" {
  for_each  = { for v in local.metallb_native : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  yaml_body = each.value
}

data "kubectl_file_documents" "metallb_config" {
  count   = var.config_manifest == null ? 0 : 1
  content = var.config_manifest
}

resource "null_resource" "metallb_wait" {
  depends_on = [kubectl_manifest.metallb_native]
  provisioner "local-exec" {
    command = "kubectl wait --namespace metallb-system --for=condition=ready pod --selector=app=metallb --timeout=90s"
  }
}

resource "kubectl_manifest" "metallb_config" {
  for_each   = { for v in local.metallb_config : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  yaml_body  = each.value
  depends_on = [null_resource.metallb_wait]
}


variable "install_manifest" {
  type = string
}

variable "config_manifest" {
  type    = string
  default = null
}
