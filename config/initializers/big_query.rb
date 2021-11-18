# frozen_string_literal: true

require "google/cloud/bigquery"

if FeatureService.enabled?("google.send_data_to_big_query")
  Google::Cloud::Bigquery.configure do |config|
    config.project_id  = Settings.google.big_query.project_id
    config.credentials = JSON.parse(Settings.google.big_query.api_json_key)
  end

  Google::Cloud::Bigquery.new
end
