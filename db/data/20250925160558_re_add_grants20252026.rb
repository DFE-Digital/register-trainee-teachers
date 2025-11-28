# frozen_string_literal: true

class ReAddGrants20252026 < ActiveRecord::Migration[7.2]
  def up
    allocation_subjects = [
      AllocationSubjects::ART_AND_DESIGN,
      AllocationSubjects::MUSIC,
      AllocationSubjects::RELIGIOUS_EDUCATION,
    ]

    # Re add missing grants for 2025-2026
    funding_method = FundingMethod.find_or_create_by!(
      training_route: ReferenceData::TRAINING_ROUTES.pg_teaching_apprenticeship.name,
      amount: 1_000,
      funding_type: FUNDING_TYPE_ENUMS[:grant],
      academic_cycle: AcademicCycle.for_year(2025),
    )

    allocation_subjects.map do |subject|
      allocation_subject = AllocationSubject.find_by!(name: subject)
      funding_method.funding_method_subjects.find_or_create_by!(allocation_subject:)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
