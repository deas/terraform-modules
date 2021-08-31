output "secret" {
  # sensitive = true
  value = {
    secret = data.google_secret_manager_secret_version.this
  }
  description = "Object describing the whole created project"
}