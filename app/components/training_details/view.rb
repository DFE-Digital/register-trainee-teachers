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
        mappable_field_row(trainee_start_date, t(".start_date")),
        mappable_field_row(trainee.trainee_id, t("components.confirmation.trainee_id.title")),
      ].compact
    end

  private

    attr_accessor :data_model, :not_provided_copy, :has_errors, :show_region

    def region
      return unless trainee&.provider&.hpitt_postgrad?

      { key: t(".region"), value: trainee.region.presence }
    end

    def trainee_start_date
      date_for_summary_view(trainee.commencement_date) if trainee.commencement_date.present?
    end

    def mappable_field_row(field_value, field_label)
      MappableFieldRow.new(
        field_value: field_value,
        field_label: field_label,
        text: t("components.confirmation.missing"),
        action_url: edit_trainee_training_details_path(trainee),
        has_errors: has_errors,
        apply_draft: trainee.apply_application?,
      ).to_h
    end
  end
end
