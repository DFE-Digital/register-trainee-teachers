# frozen_string_literal: true

class CreateSubjectSpecialisms < ActiveRecord::Migration[6.1]
  def change
    create_table :subject_specialisms do |t|
      t.string :name, null: false, index: { unique: true }
      t.references :allocation_subject, null: false, foreign_key: true

      t.timestamps
    end
  end
end
