# frozen_string_literal: true

class AddPlacementsSlug < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_column :placements, :slug, :citext
    add_index :placements, %i[slug trainee_id], unique: true, algorithm: :concurrently
  end
end
