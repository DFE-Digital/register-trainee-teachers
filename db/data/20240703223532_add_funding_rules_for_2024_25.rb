# frozen_string_literal: true

class AddFundingRulesFor202425 < ActiveRecord::Migration[7.1]
  def up
    # Add new Allocation Subjects for 2024/25 funding rules and update Subject Specialisms
    [
      AllocationSubjects::FRENCH_LANGUAGE,
      AllocationSubjects::GERMAN_LANGUAGE,
      AllocationSubjects::SPANISH_LANGUAGE,
    ].each do |allocation_subject_name|
      AllocationSubject.find_or_create_by!(name: allocation_subject_name).tap do |allocation_subject|
        SubjectSpecialism.find_by(name: allocation_subject_name).update(allocation_subject:)
      end
    end

    # Update funding rules for 2024/25
    academic_cycle = AcademicCycle.for_year(2024)

    BURSARIES_2024_TO_2025.each do |b|
      bursary = FundingMethod.find_or_create_by!(
        training_route: b.training_route,
        amount: b.amount,
        funding_type: FUNDING_TYPE_ENUMS[:bursary],
        academic_cycle: academic_cycle,
      )
      b.allocation_subjects.map do |subject|
        allocation_subject = AllocationSubject.find_by!(name: subject)
        bursary.funding_method_subjects.find_or_create_by!(allocation_subject:)
      end
    end

    SCHOLARSHIPS_2024_TO_2025.each do |s|
      funding_method = FundingMethod.find_or_create_by!(
        training_route: s.training_route,
        amount: s.amount,
        funding_type: FUNDING_TYPE_ENUMS[:scholarship],
        academic_cycle: academic_cycle,
      )
      s.allocation_subjects.map do |subject|
        allocation_subject = AllocationSubject.find_by!(name: subject)
        funding_method.funding_method_subjects.find_or_create_by!(allocation_subject:)
      end
    end

    GRANTS_2024_TO_2025.each do |g|
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
