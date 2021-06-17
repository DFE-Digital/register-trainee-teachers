# frozen_string_literal: true

class CreateAllocationSubjects < ActiveRecord::Migration[6.1]
  def change
    create_table :allocation_subjects do |t|
      t.string :name, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
