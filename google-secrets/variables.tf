variable "project_id" {
  type        = string
  description = "project id"
}

variable "gcp_credentials" {
  type        = string
  description = "gcp credentials"
}

variable "secrets" {
  type        = set(string)
  description = "the secret"
}
