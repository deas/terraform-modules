variable "flux_github_owner" {
  type        = string
  description = "github owner name"
}

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

variable "cluster" {
  type = string
}
