# frozen_string_literal: true

class AddPlacementDetailToTrainees < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_column :trainees, :placement_detail, :integer
    add_index :trainees, :placement_detail, algorithm: :concurrently
  end
end
