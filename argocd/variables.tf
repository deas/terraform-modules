#variable "github_token" {
#  type        = string
#  description = "github token"
#}

variable "namespace" {
  type    = string
  default = "argocd"
}

variable "application_manifest" {
  type    = string
  default = null
}

variable "cluster_manifest" {
  type    = string
  default = null
}

variable "bootstrap_path" {
  type    = string
  default = null
}

variable "additional_keys" {
  type    = map(any)
  default = {}
}

/*
variable "gcp_secrets_credentials" {
  type = string
}

variable "gcp_secrets_project_id" {
  type = string
}

variable "argocd_secrets" {
  type = set(string)
}
*/