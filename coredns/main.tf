terraform {
  required_version = ">= 1.2"

  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.10.0"
    }

  }
}

locals {
  corefile = [
    for v in data.kubectl_file_documents.corefile.documents : {
      data : yamldecode(v)
      content : v
    }
  ]
}

data "kubectl_file_documents" "corefile" {
  content = templatefile("${path.module}/corefile.yaml.tmpl", {
    hosts     = var.hosts
    name      = var.name
    namespace = var.namespace
  })
}

resource "kubectl_manifest" "corefile" {
  for_each  = { for v in local.corefile : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  yaml_body = each.value
}

