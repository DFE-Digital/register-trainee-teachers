# frozen_string_literal: true

module Api
  class PersonalDetailsForm < ::PersonalDetailsForm
    # override or skip validations from parent form
    # before_validation :set_nationalities_from_raw_values, if: false
    validate :nationalities_cannot_be_empty, if: false
  end
end
