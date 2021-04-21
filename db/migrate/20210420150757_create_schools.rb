# frozen_string_literal: true

class CreateSchools < ActiveRecord::Migration[6.1]
  def change
    create_table :schools do |t|
      t.string :urn, null: false
      t.string :name, null: false
      t.string :postcode, null: false
      t.string :town, null: false
      t.date :open_date
      t.date :close_date

      t.timestamps
    end

    add_index :schools, :urn, unique: true
  end
end
