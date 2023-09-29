# frozen_string_literal: true

module BulkUpdate
  class AnalyticsJob < ApplicationJob
    def perform(model:, ids:)
      DfE::Analytics::SendEvents.do(analytics_events.as_json)
    end

  private

    def events
      @events ||= records.map do |record|
        DfE::Analytics::Event.new
                              .with_type('update_entity')
                              .with_entity_table_name(model)
                              .with_data(DfE::Analytics.extract_model_attributes(record))
      end.as_json
    end

    def records
      @records ||= model.find(ids)
    end
  end
end
