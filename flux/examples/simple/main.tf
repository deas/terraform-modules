# https://github.com/hashicorp/terraform/issues/28580#issuecomment-831263879
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.2"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.10.0"
    }
  }
}

provider "kubernetes" {
  # Use KUBE_CONFIG_PATH environment
}

provider "kubectl" {
  # Use KUBECONFIG environment
  # load_config_file = false
}

locals {
  filename_flux_install = "./clusters/${var.cluster}/flux-system/gotk-components.yaml"
  filename_flux_sync    = "./clusters/${var.cluster}/flux-system/gotk-sync.yaml"
  additional_keys = zipmap(
    keys(var.additional_keys),
    [for secret in values(var.additional_keys) :
      zipmap(
        keys(secret),
      [for path in values(secret) : file(path)])
  ])
}

module "flux" {
  source = "../.."
  # version
  github_owner    = var.flux_github_owner
  repository_name = var.flux_repository_name
  target_path     = var.target_path
  branch          = var.flux_branch
  flux_install    = file(local.filename_flux_install)
  flux_sync       = file(local.filename_flux_sync)
  tls_key = {
    private = file(var.id_rsa_fluxbot_ro_path)
    public  = file(var.id_rsa_fluxbot_ro_pub_path)
  }
  additional_keys = local.additional_keys
}

# Ugly git submodule workaround
#module "flux-manifests" {
#  source = "git::https://github.com/.../foo-deployment.git//clusters/test/flux-system"
#}