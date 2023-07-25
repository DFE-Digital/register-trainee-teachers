# frozen_string_literal: true

module AwardDetails
  class View < GovukComponent::Base
    include SummaryHelper

    attr_reader :trainee

    def initialize(trainee)
      @trainee = trainee
    end

    def award_date
      if trainee.awarded_at.present?
        date_for_summary_view(trainee.awarded_at)
      elsif trainee.recommended_for_award?
        "Waiting for award - met standards on #{date_for_summary_view(trainee.recommended_for_award_at)}"
      end
    end
  end
end
