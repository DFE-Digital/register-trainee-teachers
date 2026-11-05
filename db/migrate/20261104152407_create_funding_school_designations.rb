# frozen_string_literal: true

class CreateFundingSchoolDesignations < ActiveRecord::Migration[8.1]
  def up
    create_enum :funding_school_designation_type, %i[disadvantaged special]

    create_table :funding_school_designations do |t|
      t.references :school, null: false, foreign_key: true
      t.references :academic_cycle, null: false, foreign_key: true
      t.column :designation, :funding_school_designation_type, null: false

      t.timestamps
    end

    add_index :funding_school_designations, %i[school_id academic_cycle_id],
              unique: true, name: "idx_funding_school_designations_unique"
  end

  def down
    drop_table :funding_school_designations

    drop_enum :funding_school_designation_type
  end
end
