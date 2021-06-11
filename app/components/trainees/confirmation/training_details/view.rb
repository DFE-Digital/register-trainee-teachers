# frozen_string_literal: true

module Trainees
  module Confirmation
    module TrainingDetails
      class View < GovukComponent::Base
        include SummaryHelper

        attr_accessor :data_model, :not_provided_copy

        def initialize(data_model:)
          @data_model = data_model
          @not_provided_copy = I18n.t("components.confirmation.not_provided")
        end

        def trainee
          data_model.is_a?(Trainee) ? data_model : data_model.trainee
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
