# frozen_string_literal: true

class CreateDttpTrainingInitiatives < ActiveRecord::Migration[6.1]
  def change
    create_table :dttp_training_initiatives do |t|
      t.jsonb :response
      t.uuid :dttp_id, null: false
      t.timestamps default: -> { "CURRENT_TIMESTAMP" }
    end

    add_index :dttp_training_initiatives, :dttp_id, unique: true
  end
end
