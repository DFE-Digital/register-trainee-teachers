# frozen_string_literal: true

class ValidateFundingMethodsAmountMatchesAvailability < ActiveRecord::Migration[8.1]
  def change
    validate_check_constraint :funding_methods, name: "funding_methods_amount_matches_availability"
  end
end
