# frozen_string_literal: true

class AmendPgtaGrantAmountsFor202526 < ActiveRecord::Migration[7.2]
  def up
    # This migration will update the amounts for the funding methods to the correct amounts
    # without risking the data for trainees who have already been registered for the year

    academic_cycle = AcademicCycle.for_year(2025)
    funding_type = FUNDING_TYPE_ENUMS[:grant]

    GRANTS_2025_TO_2026.each do |grant_type|
      FundingMethod.joins(:allocation_subjects)
      .where(academic_cycle: academic_cycle,
             funding_type: funding_type,
             "allocation_subjects.name": grant_type.allocation_subjects,
             training_route: grant_type.training_route).update_all(amount: grant_type.amount)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
