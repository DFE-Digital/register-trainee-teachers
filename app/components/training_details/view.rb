# frozen_string_literal: true

module TrainingDetails
  class View < GovukComponent::Base
    include SummaryHelper

    def initialize(data_model:, has_errors: false)
      @data_model = data_model
      @has_errors = has_errors
    end

    def trainee
      data_model.is_a?(Trainee) ? data_model : data_model.trainee
    end

    def training_details_rows
      [
        region,
        MappableFieldRow.new(
          field_value: trainee.trainee_id,
          field_label: t(".title"),
          text: t("components.confirmation.missing"),
          action_url: edit_trainee_training_details_path(trainee),
          has_errors: has_errors,
          apply_draft: trainee.apply_application?,
        ).to_h,
      ].compact
    end

  private

    attr_accessor :data_model, :has_errors

    def region
      return unless trainee&.provider&.hpitt_postgrad?

      { key: t(".region"), value: trainee.region.presence }
    end
  end
end
