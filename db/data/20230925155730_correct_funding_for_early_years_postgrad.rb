# frozen_string_literal: true

class CorrectFundingForEarlyYearsPostgrad < ActiveRecord::Migration[7.0]
  def up
    FundingMethod.find_by(training_route: "early_years_postgrad", academic_cycle: AcademicCycle.current, amount: 14000).update(amount: 5000)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
