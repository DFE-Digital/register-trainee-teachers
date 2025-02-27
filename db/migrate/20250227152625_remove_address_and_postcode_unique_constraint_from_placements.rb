# frozen_string_literal: true

class RemoveAddressAndPostcodeUniqueConstraintFromPlacements < ActiveRecord::Migration[7.2]
  def change
    remove_index :placements, %i[trainee_id address postcode]
  end
end
