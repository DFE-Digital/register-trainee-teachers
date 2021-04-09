# frozen_string_literal: true

class CreateDttpProviders < ActiveRecord::Migration[6.1]
  def change
    create_table :dttp_providers do |t|
      t.string :name
      t.string :dttp_id, index: { unique: true }
      t.string :ukprn

      t.timestamps default: -> { "CURRENT_TIMESTAMP" }
    end
  end
end
