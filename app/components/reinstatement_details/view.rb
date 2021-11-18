# frozen_string_literal: true

module ReinstatementDetails
  class View < GovukComponent::Base
    include SummaryHelper

    attr_reader :data_model

    def initialize(data_model)
      @data_model = data_model
    end

    def reinstate_date
      deferred_before_starting? ? t(".reinstated_before_starting") : date_for_summary_view(data_model.date)
    end

    def deferred_before_starting?
      data_model.date.nil?
    end
  end
end
