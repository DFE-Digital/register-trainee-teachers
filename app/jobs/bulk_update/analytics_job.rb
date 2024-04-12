# frozen_string_literal: true

module BulkUpdate
  class AnalyticsJob < ApplicationJob
    def perform(model:, ids:)
      return unless DfE::Analytics.enabled?

      @model = model
      @ids = ids

      DfE::Analytics::SendEvents.do(events)
    end

  private

    def events
      @events ||= records.map do |record|
        DfE::Analytics::Event.new
                              .with_type("update_entity")
                              .with_entity_table_name(@model.table_name)
                              .with_data(DfE::Analytics.extract_model_attributes(record))
      end.as_json
    end

    def records
      @records ||= @model.find(@ids)
    end
  end
end
