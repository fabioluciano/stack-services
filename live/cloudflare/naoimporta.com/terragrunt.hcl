include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/cloudflare"
}

inputs = {
  domain_name = basename(get_terragrunt_dir())

  enable_fastmail = true
  fastmail_dav_id = "d5787015"

  redirect_rules = [
    { from = "naoimporta.com", to = "https://fabioluciano.com" },
  ]
}
