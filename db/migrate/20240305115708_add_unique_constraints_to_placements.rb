# frozen_string_literal: true

class AddUniqueConstraintsToPlacements < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    Placement.where(urn: "").update_all(urn: nil)
    add_index :placements, %i[trainee_id urn], unique: true, where: "(school_id IS NULL)", algorithm: :concurrently
    add_index :placements, %i[trainee_id address postcode], unique: true, where: "(school_id IS NULL)", algorithm: :concurrently
  end

  def down
    remove_index :placements, column: %i[trainee_id urn], algorithm: :concurrently
    remove_index :placements, column: %i[trainee_id address postcode], algorithm: :concurrently
  end
end
