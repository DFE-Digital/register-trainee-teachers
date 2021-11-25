class AddContactDttpIdToPlacementAssignments < ActiveRecord::Migration[6.1]
  def change
    add_column :dttp_placement_assignments, :contact_dttp_id, :string, null: false
  end
end
