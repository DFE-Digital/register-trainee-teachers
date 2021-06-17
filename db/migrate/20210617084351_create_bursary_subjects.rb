# frozen_string_literal: true

class CreateBursarySubjects < ActiveRecord::Migration[6.1]
  def change
    create_table :bursary_subjects do |t|
      t.belongs_to :bursary
      t.belongs_to :allocation_subject

      t.timestamps
    end

    add_index :bursary_subjects, %i[allocation_subject_id bursary_id], unique: true
  end
end
