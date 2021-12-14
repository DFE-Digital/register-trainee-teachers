# frozen_string_literal: true

class RemoveStateFromDttpPlacementAssignment < ActiveRecord::Migration[6.1]
  def change
    remove_column :dttp_placement_assignments, :state, :integer, default: 0
  end
end
