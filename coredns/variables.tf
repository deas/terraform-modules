variable "hosts" {
  type    = map(any)
  default = {}
}

variable "name" {
  type    = string
  default = "coredns"
}

variable "namespace" {
  type    = string
  default = "kube-system"
}