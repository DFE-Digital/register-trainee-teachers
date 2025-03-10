# frozen_string_literal: true

# This service is used to find all draft trainees that do not have any valid data for their forms and are considered to be empty.
class FindEmptyTrainees
  include ServicePattern

  TRAINEE_FIELDS = %w[
    trainees.first_names
    trainees.last_name
    trainees.date_of_birth
    trainees.email
    trainees.middle_names
    trainees.sex
    trainees.diversity_disclosure
    trainees.ethnic_group
    trainees.ethnic_background
    trainees.additional_ethnic_background
    trainees.disability_disclosure
    trainees.course_subject_one
    trainees.itt_start_date
    trainees.outcome_date
    trainees.itt_end_date
    trainees.trn
    trainees.submitted_for_trn_at
    trainees.defer_date
    trainees.recommended_for_award_at
    trainees.trainee_start_date
    trainees.reinstate_date
    trainees.employing_school_id
    trainees.apply_application_id
    trainees.course_min_age
    trainees.course_max_age
    trainees.course_uuid
    trainees.course_subject_two
    trainees.course_subject_three
    trainees.awarded_at
    trainees.applying_for_bursary
    trainees.training_initiative
    trainees.bursary_tier
    trainees.study_mode
    trainees.region
    trainees.course_education_phase
    trainees.applying_for_scholarship
    trainees.iqts_country
  ].freeze

  EARLY_YEARS_FIELDS_TO_EXCLUDE = %w[
    trainees.course_subject_one
    trainees.course_min_age
    trainees.course_max_age
    trainees.course_education_phase
  ].freeze

  class FieldsDoNotExistError < StandardError; end

  attr_reader :trainees, :ids_only, :forms

  def initialize(trainees: Trainee.all, ids_only: false)
    raise(FieldsDoNotExistError) unless trainee_fields_exist?

    @trainees = trainees
    @ids_only = ids_only
  end

  def call
    ids_only ? empty_draft_trainee_ids : empty_draft_trainees
  end

private

  def trainee_fields_exist?
    TRAINEE_FIELDS.all? do |field|
      Trainee.column_names.include?(field.gsub("trainees.", ""))
    end
  end

  def empty_draft_trainees
    # Finds all the draft trainees that do not have any degrees, disabilities and nationalities.
    trainees
      .draft
      .where(provider_trainee_id: nil)
      .includes(:degrees, :disabilities, :nationalities, :withdrawal_reasons)
      .where(degrees: { id: nil }, disabilities: { id: nil }, nationalities: { id: nil }, withdrawal_reasons: { id: nil })
      .where(empty_fields_query)
  end

  def empty_draft_trainee_ids
    Rails.cache.fetch("#{trainees.cache_key_with_version}/empty_draft_trainee_ids") do
      empty_draft_trainees.pluck(:id)
    end
  end

  def empty_fields_query
    <<~SQL
        (
          course_subject_one = '#{CourseSubjects::EARLY_YEARS_TEACHING}'
        AND
          concat(#{(TRAINEE_FIELDS - EARLY_YEARS_FIELDS_TO_EXCLUDE).join(',')}) = ''
        )
      OR
        (
          concat(#{TRAINEE_FIELDS.join(',')}) = ''
        )
    SQL
  end
end
