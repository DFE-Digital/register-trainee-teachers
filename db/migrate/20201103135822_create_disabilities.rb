# frozen_string_literal: true

class CreateDisabilities < ActiveRecord::Migration[6.0]
  def change
    create_table :disabilities do |t|
      t.string :name, null: false, index: { unique: true }
      t.string :description, null: true
      t.timestamps
    end
  end
end
