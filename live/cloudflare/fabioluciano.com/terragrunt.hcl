include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/cloudflare"
}

inputs = {
  domain_name = basename(get_terragrunt_dir())

  enable_github_pages = true
  enable_fastmail     = true
  fastmail_dav_id     = "d5786983"

  redirect_rules = [
    { from = "cv.fabioluciano.com", to = "https://resume.fabioluciano.com" },
  ]

  custom_dns_records = [
    { type = "CNAME", name = "devex.book", value = "domains.gumroad.com" },
    { type = "CNAME", name = "resume", value = "fabioluciano.github.io" },
    { type = "CNAME", name = "guides", value = "fabioluciano.github.io" },
  ]
}
