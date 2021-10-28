# frozen_string_literal: true

class UpdateGrants < ActiveRecord::Migration[6.1]
  def up
    SEED_GRANTS.each do |s|
      funding_method = FundingMethod.find_or_create_by!(training_route: s.training_route, amount: s.amount, funding_type: FUNDING_TYPE_ENUMS[:grant])
      s.allocation_subjects.map do |subject|
        allocation_subject = AllocationSubject.find_by!(name: subject)
        funding_method.funding_method_subjects.find_or_create_by!(allocation_subject: allocation_subject)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
