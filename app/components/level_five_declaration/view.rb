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
        course_date_row(:itt_start_date, trainee.itt_start_date),
        course_date_row(:expected_end_date, trainee.itt_end_date),
      ].compact
    end

  private

    attr_accessor :data_model, :has_errors, :editable, :header_level

    def answer
      value = data_model.level_five_qualification
      return if value.nil?

      t(value ? ".yes" : ".no")
    end

    # The dates are entered in course details (the end date can be filled in
    # from the answer, Trainees::SetLevelFiveEndDate), so they're changed there.
    def course_date_row(label, date)
      return if date.blank?

      MappableFieldRow.new(
        field_value: date.to_fs(:govuk),
        field_label: t(".#{label}"),
        text: "missing",
        action_url: edit_trainee_course_details_path(trainee),
        editable: editable,
      ).to_h
    end

    # Set by the answer, so there's nothing to change here.
    def course_duration_row
      return if data_model.level_five_qualification.nil?

      value = if data_model.level_five_qualification
                t(".years", count: TrainingRouteManager::LEVEL_FIVE_COURSE_YEARS.fetch(true))
              else
                t(".standard_course_duration")
              end
      { key: t(".course_duration"), value: value }
    end
  end
end
