# frozen_string_literal: true

class CreateRelevantDegreeSubjects < ActiveRecord::Migration[8.1]
  def change
    create_table :relevant_degree_subjects do |t|
      t.references :academic_cycle, null: false, foreign_key: true
      t.references :allocation_subject, null: false, foreign_key: true
      t.string :hecos_code, null: false

      t.timestamps
    end

    add_index :relevant_degree_subjects, %i[academic_cycle_id allocation_subject_id hecos_code],
              unique: true, name: "idx_relevant_degree_subjects_unique"
  end
end
