# frozen_string_literal: true

class FormStore
  class InvalidKeyError < StandardError; end

  FORM_SECTION_KEYS = %i[
    personal_details
    contact_details
    trainee_id
    trainee_start_date
    deferral
    reinstatement
    outcome
    withdrawal
    diversity_disclosure
    ethnic_group
    ethnic_background
    disability_disclosure
    disability_detail
    diversity
  ].freeze

  class << self
    def get(trainee_id, key)
      value = Redis.current.get("#{trainee_id}_#{key}")
      JSON.parse(value) if value.present?
    end

    def set(trainee_id, key, values)
      raise InvalidKeyError unless FORM_SECTION_KEYS.include?(key)

      Redis.current.set("#{trainee_id}_#{key}", values.to_json)

      true
    end

    def clear_all(trainee_id)
      FORM_SECTION_KEYS.each do |key|
        Redis.current.set("#{trainee_id}_#{key}", nil)
      end
    end
  end
end
