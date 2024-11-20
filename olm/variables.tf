#variable "kustomization_path" {
#  type        = string
#  default     = "assets/olm"
#  description = "Default path to OLM Kustomization"
#}

# TODO: Downloading from releases causes content type warning - ugly, but at least transparent
variable "url_olm_crds" {
  type    = string
  default = "https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.30.0/crds.yaml"
  # default = "https://raw.githubusercontent.com/operator-framework/operator-lifecycle-manager/master/deploy/upstream/quickstart/crds.yaml"
}

variable "url_olm" {
  type    = string
  default = "https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.30.0/olm.yaml"
  # default = "https://raw.githubusercontent.com/operator-framework/operator-lifecycle-manager/master/deploy/upstream/quickstart/olm.yaml"
}

variable "namespace" {
  type    = string
  default = "olm" # FIXME - static atm
}
