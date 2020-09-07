resource cloudfoundry_service_instance postgres_instance {
  name         = local.postgres_service_name
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.postgres.service_plans["${var.postgres_service_plan}"]
}

resource cloudfoundry_service_instance redis_instance {
  name         = local.redis_service_name
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.redis.service_plans["${var.redis_service_plan}"]
}

resource cloudfoundry_app web_app {
  name                       = local.web_app_name
  command                    = local.web_app_start_command
  docker_image               = var.app_docker_image
  health_check_type          = "http"
  health_check_http_endpoint = "/pages/home" #TODO needs investigating further
  instances                  = var.web_app_instances
  memory                     = var.web_app_memory
  space                      = data.cloudfoundry_space.space.id
  stopped                    = var.app_stopped
  strategy                   = var.web_app_deployment_strategy
  timeout                    = var.app_start_timeout
  environment                = local.app_environment_variables
  routes {
    route = cloudfoundry_route.web_app_route.id
  }
  service_binding {
    service_instance = cloudfoundry_service_instance.postgres_instance.id
  }
  service_binding {
    service_instance = cloudfoundry_service_instance.redis_instance.id
  }
}

resource cloudfoundry_route web_app_route {
  domain   = data.cloudfoundry_domain.cloudapps_digital.id
  space    = data.cloudfoundry_space.space.id
  hostname = local.web_app_name
}
