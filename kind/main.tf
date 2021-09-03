# https://github.com/hashicorp/terraform/issues/28580#issuecomment-831263879
terraform {
  required_providers {
    kind = {
      source  = "kyma-incubator/kind"
      version = "0.0.9" # ~> 1.0"
    }
    /*
    github = {
      source  = "integrations/github"
      version = ">= 4.5.2"
    }*/
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.2"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.10.0"
    }
    /* flux = {
      source  = "fluxcd/flux"
      version = ">= 0.0.13"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.1.0"
    }*/
  }
}

provider "kind" {
}

provider "kubernetes" {
  # config_path = kind_cluster.default.kubeconfig
  # config_context = "kind-search"
  host                   = kind_cluster.default.endpoint
  client_certificate     = kind_cluster.default.client_certificate
  client_key             = kind_cluster.default.client_key
  cluster_ca_certificate = kind_cluster.default.cluster_ca_certificate
}

provider "kubectl" {
  host                   = kind_cluster.default.endpoint
  client_certificate     = kind_cluster.default.client_certificate
  client_key             = kind_cluster.default.client_key
  cluster_ca_certificate = kind_cluster.default.cluster_ca_certificate
  # token                  = data.aws_eks_cluster_auth.main.token
  load_config_file = false
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
  // TODO: Should be covered by wait_for_ready
  provisioner "local-exec" {
    command = "kubectl -n kube-system wait --timeout=180s --for=condition=ready pod -l tier=control-plane"
  }
}

locals {
  filename_flux_install = "./clusters/${var.cluster}/flux-system/gotk-components.yaml"
  filename_flux_sync    = "./clusters/${var.cluster}/flux-system/gotk-sync.yaml"
}

module "flux" {
  source = "../flux"
  # version
  github_owner    = var.flux_github_owner
  repository_name = var.flux_repository_name
  target_path     = var.target_path
  branch          = var.flux_branch
  flux_install    = file(local.filename_flux_install)
  flux_sync       = file(local.filename_flux_sync)
  tls_key = {
    private = module.secrets.secret["id-rsa-fluxbot-ro"].secret_data
    public  = module.secrets.secret["id-rsa-fluxbot-ro-pub"].secret_data
  }
  additional_keys = {
    sops-gpg = {
      "sops.asc" = module.secrets.secret["sops-gpg"].secret_data
    }
  }
  providers = {
    kubernetes = kubernetes
  }
}

module "secrets" {
  source = "../google-secrets"
  # version
  gcp_credentials = var.gcp_secrets_credentials
  project_id      = var.gcp_secrets_project_id
  secrets         = var.flux_secrets
}

#module "flux-manifests" {
#  source = "git::https://github.com/MediaMarktSaturn/search-deployment.git//clusters/test/flux-system"
#}

#data "flux_install" "main" {
#  # count       = var.github_init ? 1 : 0
#  target_path = var.target_path
#}

