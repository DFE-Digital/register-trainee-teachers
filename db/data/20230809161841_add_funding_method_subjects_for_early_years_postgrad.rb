# frozen_string_literal: true

class AddFundingMethodSubjectsForEarlyYearsPostgrad < ActiveRecord::Migration[7.0]
  def up
    allocation_subject = AllocationSubject.find_by(
      name: "Early years ITT",
    )

    FundingMethod.where(training_route: "early_years_salaried").each do |salaried_funding_method|
      postgrad_funding_method = FundingMethod.find_or_create_by(
        training_route: "early_years_postgrad",
        academic_cycle_id: salaried_funding_method.academic_cycle_id,
        amount: salaried_funding_method.amount,
        funding_type: salaried_funding_method.funding_type,
      )
      FundingMethodSubject.find_or_create_by(
        funding_method: postgrad_funding_method,
        allocation_subject: allocation_subject,
      )
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
