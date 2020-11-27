resource statuscake_test alert {

  website_name   = var.alerts["alert"]["website_name"]
  website_url    = var.alerts["alert"]["website_url"]
  test_type      = var.alerts["alert"]["test_type"]
  check_rate     = var.alerts["alert"]["check_rate"]
  contact_group  = var.alerts["alert"]["contact_group"]
  trigger_rate   = var.alerts["alert"]["trigger_rate"]
  custom_header  = var.alerts["alert"]["custom_header"]
  status_codes   = var.alerts["alert"]["status_codes"]
  confirmations  = 1
  node_locations = var.alerts["alert"]["node_locations"]
}
