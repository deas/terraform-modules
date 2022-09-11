# https://github.com/hashicorp/terraform/issues/28580#issuecomment-831263879
terraform {
  required_providers {
    kind = {
      source  = "kyma-incubator/kind"
      version = "0.0.11" # ~> 1.0"
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
  # config_context = "kind-flux"
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

locals {
  additional_keys = zipmap(
    keys(var.additional_keys),
    [for secret in values(var.additional_keys) :
      zipmap(
        keys(secret),
      [for path in values(secret) : file(path)])
  ])
}

resource "kind_cluster" "default" {
  name           = "flux"
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

module "flux" {
  source = "../.."
  # version
  github_owner    = var.flux_github_owner
  repository_name = var.flux_repository_name
  target_path     = var.target_path
  branch          = var.flux_branch
  flux_install    = file("${var.filename_flux_path}/gotk-components.yaml")
  flux_sync       = file("${var.filename_flux_path}/gotk-sync.yaml")
  tls_key = {
    private = file(var.id_rsa_fluxbot_ro_path)
    public  = file(var.id_rsa_fluxbot_ro_pub_path)
  }
  additional_keys = local.additional_keys
  /*
  tls_key = {
    private = module.secrets.secret["id-rsa-fluxbot-ro"].secret_data
    public  = module.secrets.secret["id-rsa-fluxbot-ro-pub"].secret_data
  }
  additional_keys = {
    sops-gpg = {
      "sops.asc" = module.secrets.secret["sops-gpg"].secret_data
    }
  }
  */
  providers = {
    kubernetes = kubernetes
  }
}

/*
module "secrets" {
  source = "../../../google-secrets"
  gcp_credentials = var.gcp_secrets_credentials
  project_id      = var.gcp_secrets_project_id
  secrets         = var.flux_secrets
}
*/

# Ugly git submodule workaround
#module "flux-manifests" {
#  source = "git::https://github.com/.../foo-deployment.git//clusters/test/flux-system"
#}

#data "flux_install" "main" {
#  # count       = var.github_init ? 1 : 0
#  target_path = var.target_path
#}
