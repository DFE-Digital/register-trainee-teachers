# frozen_string_literal: true

class DeleteEarlyYearsSalariedBursary < ActiveRecord::Migration[6.1]
  def up
    # NOTE: `EARLY_YEARS_GRANT` is incorrectly set as bursary
    early_years_bursary = FundingMethod.find_by(training_route: EARLY_YEARS_GRANT.training_route, amount: EARLY_YEARS_GRANT.amount, funding_type: FUNDING_TYPE_ENUMS[:bursary])

    early_years_bursary.delete
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
