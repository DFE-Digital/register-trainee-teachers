module "statuscake" {
  for_each = var.statuscake_alerts

  source = "git::https://github.com/DFE-Digital/terraform-modules.git//monitoring/statuscake?ref=testing"

  uptime_urls    = each.value.website_url
  contact_groups = each.value.contact_group
}
