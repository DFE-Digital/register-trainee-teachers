# frozen_string_literal: true

class RemoveNullConstraintFromDttpPlacementAssignments < ActiveRecord::Migration[6.1]
  def change
    change_column_null :dttp_placement_assignments, :contact_dttp_id, true
  end
end
