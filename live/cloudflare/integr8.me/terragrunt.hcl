locals {
  dirname_domainname = basename(get_terragrunt_dir())
}

include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "../../../modules/cloudflare"
}

inputs = {
  cloudflare_email = get_env("CLOUDFLARE_MAIL")
  cloudflare_api_token = get_env("CLOUDFLARE_API_TOKEN")

  domain_name = local.dirname_domainname

  enable_github_pages = true

  github_pages_dns_records    = include.root.inputs.default_github_pages_dns_records
}
