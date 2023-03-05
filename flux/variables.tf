/*
variable "target_path" {
  type        = string
  description = "flux sync target path"
}
*/

variable "bootstrap_manifest" {
  type    = string
  default = null
}

variable "namespace" {
  type    = string
  default = "flux-system" # must exist
}

variable "flux_install" {
  type = string
}

variable "flux_sync" {
  type = string
}

variable "tls_key" {
  type    = map(string)
  default = null
}

variable "additional_keys" {
  type    = map(any)
  default = {}
}
