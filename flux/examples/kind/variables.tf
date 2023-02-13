#variable "github_token" {
#  type        = string
#  description = "github token"
#}

variable "flux_github_owner" {
  type        = string
  description = "github owner"
}

/*
variable "flux_repository_visibility" {
  type        = string
  default     = "private"
  description = "How visible is the github repo"
}
*/

variable "flux_repository_name" {
  type        = string
  description = "github repository name"
}

variable "flux_branch" {
  type        = string
  default     = "main"
  description = "branch name"
}

variable "target_path" {
  type        = string
  description = "flux sync target path"
}

/*
variable "github_init" {
  type        = bool
  default     = false
  description = "Initialize github files"
}
*/

variable "id_rsa_fluxbot_ro_path" {
  type = string
}

variable "id_rsa_fluxbot_ro_pub_path" {
  type = string
}

variable "additional_keys" {
  type    = map(any)
  default = {}
}

variable "filename_flux_path" {
  type    = string
  default = "../simple/clusters/local/flux-system"
}

/*
variable "gcp_secrets_credentials" {
  type = string
}

variable "gcp_secrets_project_id" {
  type = string
}

variable "flux_secrets" {
  type = set(string)
}

variable "cluster" {
  type = string
}
*/