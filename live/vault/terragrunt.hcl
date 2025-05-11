include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  client_id     = get_env("HCP_CLIENT_ID")
  client_secret = get_env("HCP_CLIENT_SECRET")
}

terraform {
  source = "../../modules/vault"
}

inputs = {
  client_id     = local.client_id
  client_secret = local.client_secret
  application_name = get_env("HCP_VAULT_APP_NAME") 
}
