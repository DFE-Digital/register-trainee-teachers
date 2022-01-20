# frozen_string_literal: true

class CreateDttpDormantPeriods < ActiveRecord::Migration[6.1]
  def change
    create_table :dttp_dormant_periods do |t|
      t.jsonb :response
      t.uuid :dttp_id, null: false
      t.uuid :placement_assignment_dttp_id
      t.timestamps default: -> { "CURRENT_TIMESTAMP" }
    end

    add_index :dttp_dormant_periods, :dttp_id, unique: true
  end
end
