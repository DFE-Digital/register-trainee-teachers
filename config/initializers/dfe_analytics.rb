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
  config.bigquery_table_name = Settings.google.big_query.table_name

  # The name of the BigQuery project we’re writing to.
  #
  config.bigquery_project_id = Settings.google.big_query.project_id

  # The name of the BigQuery dataset we're writing to.
  #
  config.bigquery_dataset = Settings.google.big_query.dataset

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

  if Rails.env.in?(%w[development review qa])
    # Path of airbyte stream config file relative to the App root (Rails.root)
    config.airbyte_stream_config_path = "terraform/aks/workspace-variables/airbyte_stream_config.json"

    # Perform airbyte checks on startup and allow airbyte config generation
    config.airbyte_enabled = ENV["BIGQUERY_AIRBYTE_DATASET"].present?

    # Set bigquery airbyte vars
    config.bigquery_hidden_policy_tag = "projects/rugged-abacus-218110/locations/europe-west2/taxonomies/69524444121704657/policyTags/6523652585511281766"
  end
end
