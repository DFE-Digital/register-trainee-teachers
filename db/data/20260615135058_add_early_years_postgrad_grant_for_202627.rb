# frozen_string_literal: true

class AddEarlyYearsPostgradGrantFor202627 < ActiveRecord::Migration[8.1]
  def up
    academic_cycle = AcademicCycle.for_year(2026)

    return if academic_cycle.nil?

    # The early years postgraduate grant was missing from the 2026/27 funding
    funding_method = FundingMethod.find_or_create_by!(
      training_route: TRAINING_ROUTE_ENUMS[:early_years_postgrad],
      amount: 9_535,
      funding_type: FUNDING_TYPE_ENUMS[:grant],
      academic_cycle: academic_cycle,
    )

    allocation_subject = AllocationSubject.find_by!(name: AllocationSubjects::EARLY_YEARS_ITT)
    funding_method.funding_method_subjects.find_or_create_by!(allocation_subject:)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
