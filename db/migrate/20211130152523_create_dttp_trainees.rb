# frozen_string_literal: true

class CreateDttpTrainees < ActiveRecord::Migration[6.1]
  def change
    create_table :dttp_trainees do |t|
      t.jsonb :response
      t.integer :state, default: 0
      t.uuid :dttp_id, null: false
      t.timestamps default: -> { "CURRENT_TIMESTAMP" }
    end

    add_index :dttp_trainees, :dttp_id, unique: true
  end
end
