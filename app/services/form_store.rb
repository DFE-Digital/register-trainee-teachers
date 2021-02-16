# frozen_string_literal: true

class FormStore
  class InvalidKeyError < StandardError; end

  FORM_SECTION_KEYS = [
    :personal_details,
  ].freeze

  class << self
    def get(key)
      Kredis.json(key).value
    end

    def set(key, values)
      raise InvalidKeyError unless FORM_SECTION_KEYS.include?(key)

      slice = Kredis.json(key)
      slice.value = values
      true
    end

    def clear_all
      FORM_SECTION_KEYS.each do |key|
        set(key, nil)
      end
    end
  end
end
