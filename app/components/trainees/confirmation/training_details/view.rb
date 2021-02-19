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

        def rows
          items = []
          items << start_date_row if trainee.requires_start_date?
          items << trainee_id_row
        end

      private

        def start_date_row
          {
            key: t("components.confirmation.start_date.title"),
            value: trainee_start_date,
            action: govuk_link_to('Change<span class="govuk-visually-hidden"> start date</span>'.html_safe,
                                  edit_trainee_training_details_path(trainee)),
          }
        end

        def trainee_id_row
          {
            key: t("components.confirmation.trainee_id.title"),
            value: trainee_id,
            action: govuk_link_to('Change<span class="govuk-visually-hidden"> trainee ID</span>'.html_safe,
                                  edit_trainee_training_details_path(trainee)),
          }
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
