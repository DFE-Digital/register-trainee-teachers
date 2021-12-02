# frozen_string_literal: true

class BackfillFundingMethodsForPreviousAcademicCycle < ActiveRecord::Migration[6.1]
  def up
    FundingMethod.update_all(academic_cycle_id: 6)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
