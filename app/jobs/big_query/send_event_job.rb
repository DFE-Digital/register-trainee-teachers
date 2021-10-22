# frozen_string_literal: true

module BigQuery
  class SendEventJob < ApplicationJob
    queue_as :low_priority

    self.logger = ActiveSupport::TaggedLogging.new(Logger.new(IO::NULL))

    def perform(event_json, dataset = Settings.google.big_query.dataset, table = Settings.google.big_query.table_name)
      return unless FeatureService.enabled?("google.send_data_to_big_query")

      bq = Google::Cloud::Bigquery.new
      dataset = bq.dataset(dataset, skip_lookup: true)
      bq_table = dataset.table(table, skip_lookup: true)
      bq_table.insert([event_json])
    end
  end
end
