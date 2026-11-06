# frozen_string_literal: true

class MakeRelevantDegreeMappingsPerHecos < ActiveRecord::Migration[8.1]
  def up
    safety_assured do
      # Reshape from one row holding an array of HECoS codes to one row per HECoS
      # code (each with its own DRCAH reference). The feature is new; any existing
      # rows are provisional dev data, so clear them rather than back-fill.
      execute("DELETE FROM relevant_degree_mappings")

      remove_index :relevant_degree_mappings, name: "idx_relevant_degree_mappings_unique"
      remove_column :relevant_degree_mappings, :hecos_codes

      add_column :relevant_degree_mappings, :hecos_code, :string, null: false
      add_column :relevant_degree_mappings, :reference_number, :integer

      add_index :relevant_degree_mappings,
                %i[academic_cycle_id allocation_subject_id hecos_code],
                unique: true, name: "idx_relevant_degree_mappings_unique"
      add_index :relevant_degree_mappings, :reference_number, unique: true
    end
  end

  def down
    safety_assured do
      remove_index :relevant_degree_mappings, column: :reference_number
      remove_index :relevant_degree_mappings, name: "idx_relevant_degree_mappings_unique"
      remove_column :relevant_degree_mappings, :reference_number
      remove_column :relevant_degree_mappings, :hecos_code
      add_column :relevant_degree_mappings, :hecos_codes, :string, array: true, null: false, default: []
      add_index :relevant_degree_mappings,
                %i[academic_cycle_id allocation_subject_id cah_level_2_code],
                unique: true, name: "idx_relevant_degree_mappings_unique"
    end
  end
end
