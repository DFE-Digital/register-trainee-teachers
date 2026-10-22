# frozen_string_literal: true

# A funding record can say a funding type isn't available, for example "no
# bursary for an unrelated degree". Those records have no amount; every other
# record still needs one.
class AddAvailabilityToFundingMethods < ActiveRecord::Migration[8.1]
  def change
    add_column :funding_methods, :availability, :integer, default: 0, null: false
    change_column_null :funding_methods, :amount, true
    add_check_constraint :funding_methods,
                         "(availability = 0 AND amount IS NOT NULL) OR (availability = 1 AND amount IS NULL)",
                         name: "funding_methods_amount_matches_availability",
                         validate: false
  end
end
