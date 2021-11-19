# frozen_string_literal: true

class CreateAcademicCycles < ActiveRecord::Migration[6.1]
  def change
    create_table :academic_cycles do |t|
      t.date :start_date, null: false
      t.date :end_date, null: false

      t.timestamps
    end
  end
end
