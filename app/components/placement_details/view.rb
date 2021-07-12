# frozen_string_literal: true

module PlacementDetails
  class View < GovukComponent::Base
    include SummaryHelper

    attr_accessor :trainee

    def initialize(trainee:)
      @trainee = trainee
      @not_provided_copy = I18n.t("components.confirmation.not_provided")
    end

    def summary_title
      I18n.t("components.placement_detail.title")
    end

    # TODO: Render the names of the trainee's placements, if any.
    def placements
      @not_provided_copy
    end
  end
end
