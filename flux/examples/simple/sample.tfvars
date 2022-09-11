flux_github_owner          = "you"
flux_branch                = "main"
flux_repository_name       = "repo-name"
id_rsa_fluxbot_ro_path     = "./id-rsa-fluxbot-ro"
id_rsa_fluxbot_ro_pub_path = "./id-rsa-fluxbot-ro-pub"
additional_keys            = { "sops-gpg" = { "sops.asc" = "./sops.asc" } }
target_path                = "clusters/local"
cluster                    = "local"