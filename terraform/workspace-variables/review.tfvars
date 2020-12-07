# PaaS
#paas_app_environment not specified here, must be passed to terraform dymamically
env_config                       = "review"
paas_space_name                  = "bat-qa"
paas_postgres_service_plan       = "tiny-unencrypted-11"
paas_redis_service_plan          = "tiny-4_x"
paas_app_start_timeout           = "60"
paas_web_app_deployment_strategy = "blue-green-v2"
paas_web_app_instances           = 1
paas_web_app_memory              = 512
paas_worker_app_instances        = 10
paas_worker_app_memory           = 512

statuscake_alerts = {}
