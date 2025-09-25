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
  end
end
