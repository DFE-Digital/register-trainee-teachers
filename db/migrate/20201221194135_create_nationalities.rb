# frozen_string_literal: true

class CreateNationalities < ActiveRecord::Migration[6.0]
  def change
    create_table :nationalities, id: :uuid do |t|
      t.string :name, null: false, index: { unique: true }
      t.timestamps
    end
  end
end
