# frozen_string_literal: true

class CreateRelevantDegreeMappings < ActiveRecord::Migration[8.1]
  def change
    create_table :relevant_degree_mappings do |t|
      t.references :academic_cycle, null: false, foreign_key: true
      t.references :allocation_subject, null: false, foreign_key: true
      t.references :created_by, foreign_key: { to_table: :users }
      t.string :cah_level_1_code, null: false
      t.string :cah_level_2_code, null: false
      t.string :hecos_codes, array: true, null: false, default: []

      t.timestamps
    end

    # One entry per (year, ITT subject, CAH level 2) — add more CAH2s as separate
    # entries; edit the HECoS list in place.
    add_index :relevant_degree_mappings,
              %i[academic_cycle_id allocation_subject_id cah_level_2_code],
              unique: true, name: "idx_relevant_degree_mappings_unique"
  end
end
