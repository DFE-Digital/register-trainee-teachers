# frozen_string_literal: true

class AddColumnsToCourses < ActiveRecord::Migration[6.1]
  def change
    change_table :courses, bulk: true do |t|
      t.column :start_date, :date, null: false
      t.column :level, :string, null: false
      t.column :age_range, :integer, null: false
      t.column :duration_in_years, :integer, null: false
      t.column :course_length, :string, null: false
      t.column :qualification, :integer, null: false
    end
  end
end
