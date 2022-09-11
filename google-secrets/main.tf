terraform {
  required_version = "> 1.0.2"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.5"
    }
  }
}

provider "google" {
  project     = var.project_id
  credentials = base64decode(var.gcp_credentials)
}

data "google_secret_manager_secret_version" "this" {
  for_each = toset(var.secrets)
  secret   = each.value
}
