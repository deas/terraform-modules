variable "bootstrap_manifest" {
  type    = string
  default = null
}

variable "namespace" {
  type    = string
  default = "flux-system"
}

variable "kustomization_path" {
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
