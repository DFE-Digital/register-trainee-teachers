# frozen_string_literal: true

class AddRecruitmentCycleYearToApplyApplications < ActiveRecord::Migration[6.1]
  def change
    add_column :apply_applications, :recruitment_cycle_year, :integer
    add_index :apply_applications, :recruitment_cycle_year
  end
end
