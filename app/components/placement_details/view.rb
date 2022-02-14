# frozen_string_literal: true

module PlacementDetails
  class View < GovukComponent::Base
    include SummaryHelper

    attr_accessor :trainee, :editable, :has_errors, :show_link

    def initialize(trainee:, link: true, has_errors: false, editable: false)
      @trainee = trainee
      @not_provided_copy = I18n.t("components.confirmation.not_provided")
      @editable = editable
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
      return false if !editable

      link
    end
  end
end
