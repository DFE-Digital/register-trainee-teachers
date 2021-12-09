# frozen_string_literal: true

class AddExtraColumnsToDttpPlacementAssignment < ActiveRecord::Migration[6.1]
  def change
    add_column :dttp_placement_assignments, :provider_dttp_id, :uuid
    add_column :dttp_placement_assignments, :academic_year, :uuid
    add_column :dttp_placement_assignments, :programme_start_date, :date
    add_column :dttp_placement_assignments, :programme_end_date, :date
    add_column :dttp_placement_assignments, :trainee_status, :uuid
  end
end
