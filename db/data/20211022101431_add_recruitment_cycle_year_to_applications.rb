# frozen_string_literal: true

class AddRecruitmentCycleYearToApplications < ActiveRecord::Migration[6.1]
  def up
    ApplyApplication.where(recruitment_cycle_year: nil).update_all(recruitment_cycle_year: Settings.current_recruitment_cycle_year)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
