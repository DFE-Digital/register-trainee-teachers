# frozen_string_literal: true

class FormStore
  class InvalidKeyError < StandardError; end

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
    lead_school
    employing_school
    lead_partner
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
  ].freeze

  class << self
    def get(trainee_id, key)
      value = redis.get(cache_key_for(trainee_id, key))
      JSON.parse(value) if value.present?
    end

    def set(trainee_id, key, values)
      raise(InvalidKeyError) unless FORM_SECTION_KEYS.include?(key)

      redis.set(cache_key_for(trainee_id, key), values.to_json)

      true
    end

    def clear_all(trainee_id)
      FORM_SECTION_KEYS.each do |key|
        redis.set(cache_key_for(trainee_id, key), nil)
      end
    end

    def cache_key_for(trainee_id, key)
      if ENV["TEST_ENV_NUMBER"].present?
        "#{trainee_id}_#{key}_#{ENV['TEST_ENV_NUMBER']}"
      else
        "#{trainee_id}_#{key}"
      end
    end

    def redis
      RedisClient.current
    end
  end
end
