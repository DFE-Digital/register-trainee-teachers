# frozen_string_literal: true

class RemoveContraintsFromPlacement < ActiveRecord::Migration[7.2]
  def up
    remove_index :placements, column: %i[trainee_id urn]
    remove_index :placements, column: %i[trainee_id address postcode]
  end

  def down
    add_index :placements, %i[trainee_id address postcode], unique: true, where: "(school_id IS NULL)", algorithm: :concurrently
    add_index :placements, %i[trainee_id urn], unique: true, where: "(urn IS NOT NULL OR urn != '' ) AND school_id IS NULL", algorithm: :concurrently
  end
end
