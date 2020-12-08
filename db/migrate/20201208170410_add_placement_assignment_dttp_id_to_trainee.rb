# frozen_string_literal: true

class AddPlacementAssignmentDttpIdToTrainee < ActiveRecord::Migration[6.0]
  def change
    add_column :trainees, :placement_assignment_dttp_id, :uuid
  end
end
