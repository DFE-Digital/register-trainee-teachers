# frozen_string_literal: true

module PlacementDetails
  class View < GovukComponent::Base
    include SummaryHelper

    attr_accessor :trainee, :system_admin, :has_errors, :show_link

    def initialize(trainee:, system_admin:, has_errors: nil, link: true)
      @trainee = trainee
      @not_provided_copy = I18n.t("components.confirmation.not_provided")
      @system_admin = system_admin
      @has_errors = has_errors
      @show_link = show_link?(link)
    end

    def summary_title
      I18n.t("components.placement_detail.title")
    end

    def placements
      @not_provided_copy
    end

  private

    def show_link?(link)
      return true if system_admin
      return false if trainee.recommended_for_award? || trainee.awarded? || trainee.withdrawn?

      link
    end
  end
end
