# frozen_string_literal: true

module OutcomeDetails
  class View < ApplicationComponent
    include SummaryHelper

    attr_reader :data_model, :editable

    def initialize(data_model, editable: true)
      @data_model = data_model
      @editable = editable
    end

    def outcome_date
      date_for_summary_view(data_model.date)
    end

    def outcome_date_with_label
      return outcome_date if outcome_date.nil? || data_model.date_string == "other"

      "#{data_model.date_string.capitalize} - #{outcome_date}"
    end
  end
end
