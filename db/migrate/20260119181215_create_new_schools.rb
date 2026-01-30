# frozen_string_literal: true

class CreateNewSchools < ActiveRecord::Migration[7.2]
  def change
    create_table :new_schools do |t|
      t.string :description

      t.timestamps
    end
  end
end
