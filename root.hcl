remote_state {
  backend      = "s3"
  disable_init = true

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket                      = "infra-state"
    key                         = "${path_relative_to_include()}/infra.tfstate"
    region                      = "auto"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
    access_key                  = get_env("CLOUDFLARE_R2_ACCESS_KEY")
    secret_key                  = get_env("CLOUDFLARE_R2_SECRET_KEY")
    endpoints                   = { s3 = get_env("CLOUDFLARE_R2_ENDPOINT") }
  }
}
