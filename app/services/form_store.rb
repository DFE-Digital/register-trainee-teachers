# frozen_string_literal: true

class FormStore
  include Cacheable

  FORM_SECTION_KEYS = %i[
    contact_details
    publish_course_details
    course_details
    personal_details
    provider_trainee_id
    trainee_start_date
    trainee_start_status
    deferral
    reinstatement
    outcome_date
    withdraw
    withdrawal_date
    trigger
    withdrawal_reasons
    future_interest
    placement_detail
    withdrawal_reasons
    withdrawal_extra_information
    diversity_disclosure
    ethnic_group
    ethnic_background
    disability_disclosure
    disability_detail
    diversity
    degrees
    employing_school
    training_partner
    schools
    training_initiative
    bursary
    grant_and_tiered_bursary
    language_specialisms
    subject_specialism
    itt_dates
    start_date_verification
    study_modes
    course_education_phase
    training_details
    iqts_country
    training_routes
    delete_trainee
    change_accredited_provider
    placements
    itt_end_date
    feedback
  ].freeze
end
