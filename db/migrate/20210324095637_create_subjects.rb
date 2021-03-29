# frozen_string_literal: true

class CreateSubjects < ActiveRecord::Migration[6.1]
  def change
    create_table :subjects do |t|
      t.string :code, null: false, index: { unique: true }
      t.string :name, null: false

      t.timestamps
    end
  end
end
