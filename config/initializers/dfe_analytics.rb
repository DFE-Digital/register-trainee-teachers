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

  # Service account JSON key for the BigQuery API. See
  # https://cloud.google.com/bigquery/docs/authentication/service-account-file
  #
  config.bigquery_api_json_key = Settings.google.big_query.api_json_key

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
  config.enable_analytics = proc { Settings.google.big_query.send_data_to_big_query }

  # The environment we’re running in. This value will be attached
  # to all events we send to BigQuery.
  #
  # config.environment = ENV.fetch('RAILS_ENV', 'development')

  # Schedule a maintenance window during which no events are streamed to BigQuery
  # in the format of '22-01-2024 19:30..22-01-2024 20:30' (UTC).
  config.bigquery_maintenance_window = "16-05-2024 08:15..16-05-2024 09:15"
end
