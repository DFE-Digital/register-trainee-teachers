# frozen_string_literal: true

class UpdateFundingTypeOnFundingMethods < ActiveRecord::Migration[6.1]
  def up
    SEED_BURSARIES.each do |b|
      funding_method = FundingMethod.find_or_create_by!(training_route: b.training_route, amount: b.amount)
      funding_method.funding_type = bursary
      b.allocation_subjects.map do |subject|
        allocation_subject = AllocationSubject.find_by!(name: subject)
        funding_method_subjects.find_or_create_by!(allocation_subject: allocation_subject)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
