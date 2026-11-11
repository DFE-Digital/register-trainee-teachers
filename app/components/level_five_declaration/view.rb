# frozen_string_literal: true

module LevelFiveDeclaration
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

    def level_five_qualification_rows
      [
        MappableFieldRow.new(
          field_value: answer,
          field_label: t(".level_five_qualification"),
          text: "missing",
          action_url: edit_trainee_level_five_declaration_path(trainee),
          has_errors: has_errors,
          editable: editable,
        ).to_h,
        course_duration_row,
        expected_end_date_row,
      ].compact
    end

  private

    attr_accessor :data_model, :has_errors, :editable, :header_level

    def answer
      value = data_model.level_five_qualification
      return if value.nil?

      t(value ? ".yes" : ".no")
    end

    # Filled in from the answer (Trainees::SetLevelFiveEndDate), or entered in course details.
    def expected_end_date_row
      return if data_model.level_five_qualification.nil? || trainee.itt_end_date.blank?

      { key: t(".expected_end_date"), value: trainee.itt_end_date.to_fs(:govuk) }
    end

    # Set by the answer, so there's nothing to change here.
    def course_duration_row
      return if data_model.level_five_qualification.nil?

      years = TrainingRouteManager::LEVEL_FIVE_COURSE_YEARS.fetch(data_model.level_five_qualification == true)
      { key: t(".course_duration"), value: t(".years", count: years) }
    end
  end
end
