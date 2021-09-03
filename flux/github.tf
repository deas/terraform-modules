#resource "tls_private_key" "main" {
#  algorithm = "RSA"
#  rsa_bits  = 4096
#}

# GitHub
#data "github_repository" "main" {
#  full_name = "${var.github_owner}/${var.repository_name}"
#}

# We don't want to create the repo
#resource "github_repository" "main" {
#  name       = var.repository_name
#  visibility = var.repository_visibility
#  auto_init  = true
#}

#resource "github_branch_default" "main" {
#  repository = github_repository.main.name
#  branch     = var.branch
#}

#resource "github_repository_deploy_key" "main" {
#  title      = "local-cluster"
#  repository = data.github_repository.main.name
#  key        = tls_private_key.main.public_key_openssh
#  read_only  = true
#}

/*
resource "github_repository_file" "install" {
  count      = var.github_init ? 1 : 0
  repository = data.github_repository.main.name
  file       = data.flux_install.main.path
  content    = data.flux_install.main.content
  branch     = var.branch
}

resource "github_repository_file" "sync" {
  count      = var.github_init ? 1 : 0
  repository = data.github_repository.main.name
  file       = data.flux_sync.main.path
  content    = data.flux_sync.main.content
  branch     = var.branch
}

resource "github_repository_file" "kustomize" {
  count      = var.github_init ? 1 : 0
  repository = data.github_repository.main.name
  file       = data.flux_sync.main.kustomize_path
  content    = data.flux_sync.main.kustomize_content
  branch     = var.branch
}
*/
