# frozen_string_literal: true

class CreateDttpBursaryDetails < ActiveRecord::Migration[6.1]
  def change
    create_table :dttp_bursary_details do |t|
      t.jsonb :response
      t.uuid :dttp_id, null: false
      t.timestamps default: -> { "CURRENT_TIMESTAMP" }
    end

    add_index :dttp_bursary_details, :dttp_id, unique: true
  end
end
