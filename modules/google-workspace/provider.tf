terraform {
  required_providers {
    googleworkspace = {
      source  = "hashicorp/googleworkspace"
      version = ">= 0.7.0"
    }
  }
}

provider "googleworkspace" {
  credentials             = var.vault_credential
  customer_id             = var.customer_id
  impersonated_user_email = var.impersonated_user_email
  oauth_scopes = [
    "https://www.googleapis.com/auth/admin.directory.user",
    "https://www.googleapis.com/auth/admin.directory.group",
  ]
}

