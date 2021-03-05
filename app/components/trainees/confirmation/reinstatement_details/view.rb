# frozen_string_literal: true

module Trainees
  module Confirmation
    module ReinstatementDetails
      class View < GovukComponent::Base
        include SummaryHelper

        attr_reader :trainee

        def initialize(trainee:)
          @trainee = trainee
        end

        def confirm_section_title
          I18n.t("components.confirmation.reinstatement_details.heading")
        end

        def reinstate_date
          date_for_summary_view(trainee.reinstate_date)
        end
      end
    end
  end
end
