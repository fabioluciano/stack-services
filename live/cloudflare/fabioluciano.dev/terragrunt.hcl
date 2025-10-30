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
  enable_google_workspace = true

  custom_dns_records = [
    {
      type = "CNAME"
      name = "k8s.fabioluciano.dev"
      value = "fabioluciano.github.io"
      proxied = true
    },
    {
      type = "A"
      name = "blog.fabioluciano.dev"
      value = "162.159.153.4"
      proxied = false
    },
    {
      type = "A"
      name = "blog.fabioluciano.dev"
      value = "162.159.152.4"
      proxied = false
    },
    {
      type = "A"
      name = "log.fabioluciano.dev"
      value = "76.76.21.21"
      proxied = false
    }
  ]

  github_pages_dns_records    = include.root.inputs.default_github_pages_dns_records
  google_workspace_mx_records = include.root.inputs.default_google_workspace_mx_records
}
