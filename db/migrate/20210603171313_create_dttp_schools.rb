# frozen_string_literal: true

class CreateDttpSchools < ActiveRecord::Migration[6.1]
  def change
    create_table :dttp_schools do |t|
      t.string :name
      t.string :dttp_id, index: { unique: true }
      t.string :urn

      t.timestamps default: -> { "CURRENT_TIMESTAMP" }
    end
  end
end
