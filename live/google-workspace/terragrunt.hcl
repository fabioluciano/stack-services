include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "vault" {
  config_path = "${path_relative_from_include()}/live/vault"
  mock_outputs = {
    secrets = {
      google_workspace_credential = "test"
      google_workspace_customer_id = "test"
      google_workspace_email = "test"
    }
  }
}

terraform {
  source = "../../modules/google-workspace"
}

inputs = {
  vault_credential =  dependency.vault.outputs.secrets["google_workspace_credential"]
  customer_id = dependency.vault.outputs.secrets["google_workspace_customer_id"]
  impersonated_user_email = dependency.vault.outputs.secrets["google_workspace_email"]
}
