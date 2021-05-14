# frozen_string_literal: true

class AddMinMaxAgeRangeColumnsToTrainees < ActiveRecord::Migration[6.1]
  def change
    change_table :trainees, bulk: true do |t|
      t.column :course_min_age, :integer
      t.column :course_max_age, :integer
    end
  end
end
