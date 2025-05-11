data "hcp_vault_secrets_app" "application" {
  app_name = var.application_name
}

output "secrets" {
  value     = data.hcp_vault_secrets_app.application.secrets
  sensitive = true
}
