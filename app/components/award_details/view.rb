# frozen_string_literal: true

module AwardDetails
  class View < GovukComponent::Base
    include SummaryHelper

    attr_reader :trainee

    def initialize(trainee)
      @trainee = trainee
    end

    def award_date
      date_for_summary_view(trainee.awarded_at)
    end
  end
end
