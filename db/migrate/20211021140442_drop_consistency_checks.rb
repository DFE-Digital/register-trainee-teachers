# frozen_string_literal: true

class DropConsistencyChecks < ActiveRecord::Migration[6.1]
  def change
    drop_table :consistency_checks do |t|
      t.integer :trainee_id
      t.datetime :contact_last_updated_at
      t.datetime :placement_assignment_last_updated_at

      t.timestamps
    end
  end
end
