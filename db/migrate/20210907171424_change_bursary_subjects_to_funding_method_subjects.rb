# frozen_string_literal: true

class ChangeBursarySubjectsToFundingMethodSubjects < ActiveRecord::Migration[6.1]
  def change
    remove_index :bursary_subjects, %w[allocation_subject_id bursary_id], name: "index_bursary_subjects_on_allocation_subject_id_and_bursary_id"
    rename_table :bursary_subjects, :funding_method_subjects
    rename_column :funding_method_subjects, :bursary_id, :funding_method_id
    # index name exceeded the maximum of 63 characters
    add_index :funding_method_subjects, %w[allocation_subject_id funding_method_id], name: "index_funding_methods_subjects_on_ids", unique: true
  end
end
