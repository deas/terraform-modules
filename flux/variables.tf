variable "repository_name" {
  type        = string
  description = "github repository name"
}

variable "repository_visibility" {
  type        = string
  default     = "private"
  description = "How visible is the github repo"
}

variable "target_path" {
  type        = string
  description = "flux sync target path"
}

variable "flux_install" {
  type = string
}

variable "flux_sync" {
  type = string
}

variable "tls_key" {
  type = map(string)
}

variable "additional_keys" {
  type    = map(any)
  default = {}
}
