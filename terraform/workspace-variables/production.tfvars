# PaaS
paas_app_environment             = "production"
env_config                       = "production"
paas_space_name                  = "bat-prod"
paas_postgres_service_plan       = "tiny-unencrypted-11"
paas_redis_service_plan          = "tiny-4_x"
paas_app_start_timeout           = "60"
paas_web_app_deployment_strategy = "blue-green-v2"
paas_web_app_instances           = 1
paas_web_app_memory              = 512
paas_worker_app_instances        = 1
paas_worker_app_memory           = 512

statuscake_alerts = {

  alert = {
    website_name   = "register-production"
    website_url    = "https://www.register-trainee-teachers.education.gov.uk/ping"
    test_type      = "HTTP"
    check_rate     = 60
    contact_group  = [188603]
    trigger_rate   = 0
    custom_header  = "{\"Content-Type\": \"application/x-www-form-urlencoded\"}"
    status_codes   = "204, 205, 206, 303, 400, 401, 403, 404, 405, 406, 408, 410, 413, 444, 429, 494, 495, 496, 499, 500, 501, 502, 503, 504, 505, 506, 507, 508, 509, 510, 511, 521, 522, 523, 524, 520, 598, 599"
    node_locations = ["UKD", "DE", "CA"]
  }
}
