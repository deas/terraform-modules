# https://github.com/hashicorp/terraform/issues/28580#issuecomment-831263879
terraform {
  required_version = ">= 1.2.0"

  required_providers {
    external = {
      source  = "hashicorp/external"
      version = ">2.2.0"
    }
  }
}

locals {
  subnet_start = join(".", slice(split(".", data.external.ipam.result["Subnet"]), 0, 2))
  ip_range     = format("%s.%s-%s.%s", local.subnet_start, var.ipam[0], local.subnet_start, var.ipam[1])
}

variable "namespace" {
  type    = string
  default = "metallb-system"
}

variable "name" {
  type    = string
  default = "example"
}

variable "network_name" {
  type    = string
  default = "kind"
}

variable "ipam" {
  type    = list(any)
  default = ["255.200", "255.250"]
}

data "external" "ipam" {
  program = ["docker", "network", "inspect", "--format", "{{ json (index .IPAM.Config 0) }}", var.network_name]
}

output "manifest" {
  value = templatefile("${path.module}/manifest.tmpl.yaml", {
    "ip_range"  = local.ip_range
    "name"      = var.name
    "namespace" = var.namespace
  })
}
