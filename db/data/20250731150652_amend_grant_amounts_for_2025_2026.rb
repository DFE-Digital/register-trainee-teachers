# frozen_string_literal: true

class AmendGrantAmountsFor20252026 < ActiveRecord::Migration[7.2]
  def up
    academic_cycle = AcademicCycle.for_year(2025)

    # Remove old grants
    FundingMethod.where(funding_type: FUNDING_TYPE_ENUMS[:grant], academic_cycle: academic_cycle).destroy_all

    # Add amended grants for 2025-2026
    GRANTS_2025_TO_2026.each do |g|
      funding_method = FundingMethod.find_or_create_by!(
        training_route: g.training_route,
        amount: g.amount,
        funding_type: FUNDING_TYPE_ENUMS[:grant],
        academic_cycle: academic_cycle,
      )
      g.allocation_subjects.map do |subject|
        allocation_subject = AllocationSubject.find_by!(name: subject)
        funding_method.funding_method_subjects.find_or_create_by!(allocation_subject:)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
