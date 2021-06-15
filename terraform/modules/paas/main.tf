terraform {
  required_providers {
    cloudfoundry = {
      source  = "cloudfoundry-community/cloudfoundry"
      version = "0.13.0"
    }
  }
}
resource cloudfoundry_service_instance postgres_instance {
  name         = local.postgres_service_name
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.postgres.service_plans[var.postgres_service_plan]
  timeouts {
    create = "30m"
    delete = "30m"
    update = "30m"
  }
}

resource cloudfoundry_service_instance worker_redis_instance {
  name         = local.redis_worker_service_name
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.redis.service_plans[var.redis_service_plan]
  json_params  = jsonencode(local.noeviction_maxmemory_policy)
  timeouts {
    create = "30m"
  }
}

resource cloudfoundry_service_instance cache_redis_instance {
  name         = local.redis_cache_service_name
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.redis.service_plans[var.redis_service_plan]
  json_params  = jsonencode(local.allkeys_lru_maxmemory_policy)
  timeouts {
    create = "30m"
  }
}

resource cloudfoundry_app web_app {
  name                       = local.web_app_name
  docker_image               = var.app_docker_image
  command                    = local.web_app_start_command
  health_check_type          = "http"
  health_check_http_endpoint = "/ping"
  instances                  = var.web_app_instances
  memory                     = var.web_app_memory
  space                      = data.cloudfoundry_space.space.id
  strategy                   = "blue-green-v2"
  timeout                    = var.app_start_timeout
  environment                = local.app_environment
  docker_credentials         = var.docker_credentials

  dynamic "routes" {
    for_each = local.web_app_routes
    content {
      route = routes.value
    }
  }

  service_binding {
    service_instance = cloudfoundry_service_instance.postgres_instance.id
  }
  service_binding {
    service_instance = cloudfoundry_service_instance.worker_redis_instance.id
  }
  service_binding {
    service_instance = cloudfoundry_service_instance.cache_redis_instance.id
  }
  service_binding {
    service_instance = cloudfoundry_user_provided_service.logging.id
  }
}


resource cloudfoundry_app worker_app {
  name               = local.worker_app_name
  command            = local.worker_app_start_command
  docker_image       = var.app_docker_image
  health_check_type  = "process"
  instances          = var.worker_app_instances
  memory             = var.worker_app_memory
  space              = data.cloudfoundry_space.space.id
  strategy           = "blue-green-v2"
  timeout            = var.app_start_timeout
  environment        = local.app_environment
  docker_credentials = var.docker_credentials
  stopped            = var.worker_app_stopped

  service_binding {
    service_instance = cloudfoundry_service_instance.worker_redis_instance.id
  }
  service_binding {
    service_instance = cloudfoundry_service_instance.cache_redis_instance.id
  }
  service_binding {
    service_instance = cloudfoundry_service_instance.postgres_instance.id
  }
  service_binding {
    service_instance = cloudfoundry_user_provided_service.logging.id
  }
}

resource cloudfoundry_route web_app_route {
  domain   = data.cloudfoundry_domain.cloudapps_digital.id
  space    = data.cloudfoundry_space.space.id
  hostname = local.web_app_name
}

resource cloudfoundry_route web_app_service_gov_uk_route {
  domain   = data.cloudfoundry_domain.register_education_gov_uk.id
  space    = data.cloudfoundry_space.space.id
  hostname = var.web_app_hostname
}

resource cloudfoundry_user_provided_service logging {
  name             = local.logging_service_name
  space            = data.cloudfoundry_space.space.id
  syslog_drain_url = var.log_url
}
