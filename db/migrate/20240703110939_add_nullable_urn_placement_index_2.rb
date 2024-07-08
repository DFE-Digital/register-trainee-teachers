# frozen_string_literal: true

class AddNullableUrnPlacementIndex2 < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    remove_index(:placements, column: %i[trainee_id urn]) if index_exists?(:placements, %i[trainee_id urn])

    add_index :placements, %i[trainee_id urn], unique: true, where: "urn IS NOT NULL AND urn != '' AND school_id IS NULL", algorithm: :concurrently
  end

  def down
    remove_index :placements, column: %i[trainee_id urn]
  end
end
