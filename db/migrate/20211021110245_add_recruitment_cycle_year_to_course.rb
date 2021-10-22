# frozen_string_literal: true

class AddRecruitmentCycleYearToCourse < ActiveRecord::Migration[6.1]
  def change
    add_column :courses, :recruitment_cycle_year, :int
    add_index :courses, :recruitment_cycle_year
  end
end
