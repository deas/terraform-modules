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
  main = try([for v in data.kubectl_file_documents.main[0].documents : {
    data : yamldecode(v)
    content : v
    }
  ], [])
}

data "kubectl_file_documents" "main" {
  count   = var.manifest == null ? 0 : 1
  content = var.manifest
}

resource "kubectl_manifest" "main" {
  for_each  = { for v in local.main : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  yaml_body = each.value
}