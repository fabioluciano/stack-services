variable "vault_credential" {
  type        = string
  description = "Credencial do Vault"
}

variable "customer_id" {
  type        = string
  description = "ID do customer"
}

variable "impersonated_user_email" {
  type        = string
  description = "Email da conta com permissão para gerenciar o Workspace"
}
