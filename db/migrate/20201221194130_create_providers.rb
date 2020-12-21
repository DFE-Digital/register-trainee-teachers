# frozen_string_literal: true

class CreateProviders < ActiveRecord::Migration[6.0]
  def change
    create_table :providers, id: :uuid do |t|
      t.string :name, null: false
      t.uuid :dttp_id
      t.timestamps
    end
  end
end
