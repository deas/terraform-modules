variable "url_olm_crds" {
  type    = string
  default = "https://raw.githubusercontent.com/operator-framework/operator-lifecycle-manager/master/deploy/upstream/quickstart/crds.yaml"
}

variable "url_olm" {
  type    = string
  default = "https://raw.githubusercontent.com/operator-framework/operator-lifecycle-manager/master/deploy/upstream/quickstart/olm.yaml"
}

variable "namespace" {
  type    = string
  default = "olm" # FIXME - static atm
}
