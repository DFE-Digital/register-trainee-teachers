# frozen_string_literal: true

DfE::Analytics.configure do |config|
  # Whether to log events instead of sending them to BigQuery.
  #
  # config.log_only = true

  # Whether to use ActiveJob or dispatch events immediately.
  #
  # config.async = true

  # Whether to run entity table checksum job.
  #
  config.entity_table_checks_enabled = Settings.google.big_query.entity_table_checks_enabled

  # Which ActiveJob queue to put events on
  #
  config.queue = :dfe_analytics

  # The name of the BigQuery table we’re writing to.
  #
  config.bigquery_table_name = 'events'

  # The name of the BigQuery project we’re writing to.
  #
  config.bigquery_project_id = 'get-into-teaching'

  # The name of the BigQuery dataset we're writing to.
  #
  config.bigquery_dataset = 'bat_cross_project'

  # Ensure JSON API Key does not get set
  config.bigquery_api_json_key = ''

  config.google_cloud_credentials = {
    universe_domain: "googleapis.com",
    type: "external_account",
    audience: "//iam.googleapis.com/projects/574582782335/locations/global/workloadIdentityPools/azure-cip-identity-pool/providers/azure-cip-oidc-provider",
    subject_token_type: "urn:ietf:params:oauth:token-type:jwt",
    token_url: "https://sts.googleapis.com/v1/token",
    credential_source: {
      url: "https://login.microsoftonline.com/9c7d9dd3-840c-4b3f-818e-552865082e16/oauth2/v2.0/token"
    },
    service_account_impersonation_url: "https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/bat-cross-project@get-into-teaching.iam.gserviceaccount.com:generateAccessToken",
    service_account_impersonation: {
      token_lifetime_seconds: 3600
    }
  }

  # Passed directly to the retries: option on the BigQuery client
  #
  # config.bigquery_retries = 3

  # Passed directly to the timeout: option on the BigQuery client
  #
  # config.bigquery_timeout = 120

  # A proc which returns true or false depending on whether you want to
  # enable analytics. You might want to hook this up to a feature flag or
  # environment variable.
  #
  # config.enable_analytics = proc { true }
  config.enable_analytics = proc { FeatureService.enabled?("google.send_data_to_big_query") }

  # The environment we’re running in. This value will be attached
  # to all events we send to BigQuery.
  #
  # config.environment = ENV.fetch('RAILS_ENV', 'development')

  # Whether to use azure workload identity federation for authentication
  # instead of the BigQuery API JSON Key. Note that this also will also
  # use a new version of the BigQuery streaming APIs.
  config.azure_federated_auth = true
end
