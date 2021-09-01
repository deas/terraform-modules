variable "github_owner" {
  type        = string
  description = "github owner"
}

#variable "github_token" {
#  type        = string
#  description = "github token"
#}

variable "repository_name" {
  type        = string
  description = "github repository name"
}

variable "repository_visibility" {
  type        = string
  default     = "private"
  description = "How visible is the github repo"
}

variable "branch" {
  type        = string
  default     = "main"
  description = "branch name"
}

variable "target_path" {
  type        = string
  description = "flux sync target path"
}

variable "github_init" {
  type        = bool
  default     = false
  description = "Initialize github files"
}

variable "gcp_secrets_credentials" {
  type = string
}

variable "gcp_secrets_project_id" {
  type = string
}

variable "secrets" {
  type = set(string)
}
