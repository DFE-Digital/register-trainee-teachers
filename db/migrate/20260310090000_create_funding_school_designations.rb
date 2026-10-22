# frozen_string_literal: true

class CreateFundingSchoolDesignations < ActiveRecord::Migration[8.1]
  def change
    create_table :funding_school_designations do |t|
      t.references :school, null: false, foreign_key: true
      t.references :academic_cycle, null: false, foreign_key: true
      t.references :created_by, foreign_key: { to_table: :users }
      t.integer :designation, null: false

      t.timestamps
    end

    # One designation per school per academic year (a school is one type in a
    # given year — disadvantaged or special).
    add_index :funding_school_designations, %i[school_id academic_cycle_id], unique: true,
                                                                             name: "idx_funding_school_designations_unique"
  end
end
