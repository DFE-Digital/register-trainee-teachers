# frozen_string_literal: true

class CreateNewTrainees < ActiveRecord::Migration[7.2]
  def change
    create_table :new_trainees do |t|
      t.string :description

      t.timestamps
    end
  end
end
