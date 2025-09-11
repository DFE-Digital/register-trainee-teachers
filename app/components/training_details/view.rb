# frozen_string_literal: true

module TrainingDetails
  class View < ApplicationComponent
    include SummaryHelper

    def initialize(data_model:, has_errors: false, editable: false, header_level: 2)
      @data_model = data_model
      @has_errors = has_errors
      @editable = editable
      @header_level = header_level
    end

    def trainee
      data_model.is_a?(Trainee) ? data_model : data_model.trainee
    end

    def training_details_rows
      [
        region,
        MappableFieldRow.new(
          field_value: trainee.provider_trainee_id,
          field_label: t(".title"),
          text: "missing",
          action_url: edit_trainee_training_details_path(trainee),
          has_errors: has_errors,
          editable: editable,
          apply_draft: trainee.apply_application?,
        ).to_h,
      ].compact
    end

  private

    attr_accessor :data_model, :has_errors, :editable, :header_level

    def region
      return unless trainee&.provider&.hpitt_postgrad?

      { key: t(".region"), value: trainee.region.presence }
    end
  end
end
