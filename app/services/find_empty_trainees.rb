# frozen_string_literal: true

# This service is used to find all draft trainees that do not have any valid data for their forms and are considered to be empty.
class FindEmptyTrainees
  include ServicePattern

  FIELDS_TO_CHECK = %w[
    first_names
    last_name
    date_of_birth
    address_line_one
    address_line_two
    town_city
    postcode
    email
    middle_names
    international_address
    trainees.locale_code
    gender
    diversity_disclosure
    ethnic_group
    ethnic_background
    additional_ethnic_background
    disability_disclosure
    course_subject_one
    course_start_date
    outcome_date
    course_end_date
    trn
    submitted_for_trn_at
    withdraw_reason
    withdraw_date
    additional_withdraw_reason
    defer_date
    recommended_for_award_at
    commencement_date
    reinstate_date
    lead_school_id
    employing_school_id
    apply_application_id
    course_min_age
    course_max_age
    course_code
    course_subject_two
    course_subject_three
    awarded_at
    applying_for_bursary
    training_initiative
    bursary_tier
    trainees.study_mode
    region
    course_education_phase
    applying_for_scholarship
  ].freeze

  EARLY_YEARS_FIELDS_TO_EXCLUDE = %w[
    course_subject_one
    course_min_age
    course_max_age
  ].freeze

  class FieldsDoNotExistError < StandardError; end

  attr_reader :trainees, :ids_only, :forms

  def initialize(trainees: Trainee.all, ids_only: false)
    @trainees = trainees
    @ids_only = ids_only
  end

  def call
    ids_only ? draft_trainees.pluck(:id) : draft_trainees
  end

private

  def draft_trainees
    # Finds all the draft trainees that do not have any degrees, disabilities and nationalities.
    trainees
      .draft
      .includes(:degrees, :disabilities, :nationalities)
      .where(degrees: { id: nil }, disabilities: { id: nil }, nationalities: { id: nil })
      .where(trainee_data_query)
  end

  def trainee_data_query
    <<~SQL
        (
          course_subject_one = \'#{CourseSubjects::EARLY_YEARS_TEACHING}\'
        AND
          concat(#{(FIELDS_TO_CHECK - EARLY_YEARS_FIELDS_TO_EXCLUDE).join(',')}) = ''
        )
      OR
        (
          concat(#{FIELDS_TO_CHECK.join(',')}) = ''
        )
    SQL
  end
end
