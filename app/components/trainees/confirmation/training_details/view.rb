# frozen_string_literal: true

module Trainees
  module Confirmation
    module TrainingDetails
      class View < GovukComponent::Base
        include SummaryHelper

        attr_accessor :trainee, :not_provided_copy

        def initialize(trainee:)
          @trainee = trainee
          @not_provided_copy = I18n.t("components.confirmation.not_provided")
        end

        def trainee_id
          trainee.trainee_id.presence || not_provided_copy
        end

        def trainee_start_date
          trainee.commencement_date.present? ? date_for_summary_view(trainee.commencement_date) : not_provided_copy
        end
      end
    end
  end
end
