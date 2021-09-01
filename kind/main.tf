terraform {
  required_providers {
    kind = {
      source  = "kyma-incubator/kind"
      version = "0.0.9" # ~> 1.0"
    }
  }
}

provider "kind" {
}

resource "kind_cluster" "default" {
  name           = "search"
  wait_for_ready = true
  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"
    }

    #node {
    #  role = "worker"
    #  image = "kindest/node:v1.19.1"
    #}
    # Guess this will work as the creation changes to context?
  }
  provisioner "local-exec" {
    command = "kubectl -n kube-system wait --timeout=180s --for=condition=ready pod -l tier=control-plane"
  }
}

module "flux" {
  source = "../flux"
  # version
  github_owner    = var.github_owner
  repository_name = var.repository_name
  target_path     = var.target_path
  branch          = var.branch
  k8s_context     = "kind-search"
  # depends_on      = [kind_cluster.default]
}

module "secrets" {
  source = "../google-secrets"
  # version
  gcp_credentials = var.gcp_secrets_credentials
  project_id      = var.gcp_secrets_project_id
  secrets         = var.secrets
}
