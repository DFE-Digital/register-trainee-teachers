# frozen_string_literal: true

class CreateFundingSchoolDesignations < ActiveRecord::Migration[8.1]
  def change
    create_table :funding_school_designations do |t|
      t.references :school, null: false, foreign_key: true
      t.references :academic_cycle, null: false, foreign_key: true
      t.string :designation, null: false

      t.timestamps
    end

    add_index :funding_school_designations, %i[school_id academic_cycle_id],
              unique: true, name: "idx_funding_school_designations_unique"
  end
end
