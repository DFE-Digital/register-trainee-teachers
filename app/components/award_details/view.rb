# frozen_string_literal: true

module AwardDetails
  class View < GovukComponent::Base
    include SummaryHelper

    attr_reader :trainee, :show_undo_award
    alias_method :show_undo_award?, :show_undo_award

    def initialize(trainee, show_undo_award: false)
      @trainee = trainee
      @show_undo_award = show_undo_award
    end

    def award_date
      if trainee.awarded_at.present?
        date_for_summary_view(trainee.awarded_at)
      elsif trainee.recommended_for_award?
        I18n.t(
          "components.award_details.waiting_for_award",
          recommended_for_award_at: date_for_summary_view(trainee.recommended_for_award_at),
        )
      end
    end
  end
end
