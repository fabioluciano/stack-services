locals {
  dirname_domainname = basename(get_terragrunt_dir())
}

include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "vault" {
  config_path = "${path_relative_from_include()}/live/vault"

  mock_outputs = {
    secrets = {
      cloudflare_email            = "test@test.com"
      cloudflare_api_token        = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    }
  }
}

terraform {
  source = "../../../modules/cloudflare"
}

inputs = {
  cloudflare_email = dependency.vault.outputs.secrets["cloudflare_email"]
  cloudflare_api_key = dependency.vault.outputs.secrets["cloudflare_api_token"]
  teste = dependency.vault.outputs.secrets

  domain_name = local.dirname_domainname

  enable_github_pages = true

  custom_dns_records = [
    {
      type = "CNAME"
      name = "k8s.fabioluciano.dev"
      value = "fabioluciano.github.io"
      proxied = true
    },
  ]

  github_pages_dns_records    = include.root.inputs.default_github_pages_dns_records
}
