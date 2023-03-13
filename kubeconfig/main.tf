terraform {
  required_version = ">= 1.2"

  required_providers {
  }
}

# TODO: Awesome! Normalizing kubernetes related provider config :(

locals {
  kubeconfig = yamldecode(var.kubeconfig != null ? var.kubeconfig : yamlencode({
    "apiVersion" : "v1"
    "current-context" = "default"
    "contexts" = [{
      "name" = "default"
      "context" = {
        "cluster" = "default"
        "user"    = "default"
      }
    }]
    "clusters" = [{
      "name" = "default"
      "cluster" = {
        "server"                     = var.host
        "certificate-authority-data" = var.cluster_ca_certificate
      }
    }]
    "users" = [{
      "name" = "default"
      "user" = [{
        "client-certificate-data" = var.client_certificate
        "client-key-data"         = var.client_key
      }]
    }]
  }))

  context-name = var.context != null ? var.context : local.kubeconfig["current-context"]

  contexts = local.kubeconfig["contexts"]
  context  = local.contexts[index(local.contexts[*]["name"], local.context-name)]

  cluster-name = local.context["context"]["cluster"]
  clusters     = local.kubeconfig["clusters"]
  cluster      = local.clusters[index(local.clusters[*]["name"], local.cluster-name)]["cluster"]

  user-name = local.context["context"]["user"]
  users     = local.kubeconfig["users"]
  user      = local.users[index(local.users[*]["name"], local.user-name)]["user"]
}

variable "kubeconfig" {
  type    = string
  default = null
  #validation {
  #  condition     = var.host == null && var.client_certificate == null && var.client_key == null && var.cluster_ca_certificate == null
  #  error_message = "This application requires at least two private subnets."
  #}
}

variable "context" {
  type    = string
  default = null
  #validation {
  #  condition     = var.kubeconfig != null
  #  error_message = "kubeconfig must be not be"
  #}
}

variable "host" {
  type    = string
  default = null
  #validation {
  #  condition     = var.kubeconfig == null
  #  error_message = "kubeconfig must be null"
  #}
}

variable "client_certificate" {
  type    = string
  default = null
  #validation {
  #  condition     = var.kubeconfig == null
  #  error_message = "kubeconfig must be null"
  #}
}

variable "client_key" {
  type    = string
  default = null
  #validation {
  #  condition     = var.kubeconfig == null
  #  error_message = "kubeconfig must be null"
  #}
}

variable "cluster_ca_certificate" {
  type    = string
  default = null
  #validation {
  #  condition     = var.kubeconfig == null
  #  error_message = "kubeconfig must be null"
  #}
}

output "context" {
  value = local.context-name
}

output "host" {
  value = local.cluster["server"]
}

output "client_certificate" {
  value = base64decode(local.user["client-certificate-data"])
}

output "client_key" {
  value = base64decode(local.user["client-key-data"])
}

output "cluster_ca_certificate" {
  value = base64decode(local.cluster["certificate-authority-data"])
}

output "kubeconfig" {
  value = yamlencode(local.kubeconfig)
}
