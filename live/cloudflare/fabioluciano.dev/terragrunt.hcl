include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/cloudflare"
}

inputs = {
  domain_name = basename(get_terragrunt_dir())

  enable_fastmail = true
  fastmail_dav_id = "d5786999"

  redirect_rules = [
    { from = "fabioluciano.dev", to = "https://fabioluciano.com" },
  ]
}
