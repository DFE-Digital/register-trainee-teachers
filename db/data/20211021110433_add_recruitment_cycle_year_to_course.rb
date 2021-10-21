# frozen_string_literal: true

class AddRecruitmentCycleYearToCourse < ActiveRecord::Migration[6.1]
  def up
    Course.update_all(recruitment_cycle_year: 2021)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
