# frozen_string_literal: true

class AddFundingMethodsFor20222023 < ActiveRecord::Migration[6.1]
  def up
    # i.e. the academic cycle 2022/23 for the recruitment year 2022
    academic_cycle = AcademicCycle.for_year(2022)

    BURSARIES_2022_TO_2023.each do |b|
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

    SCHOLARSHIPS_2022_TO_2023.each do |s|
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

    GRANTS_2022_TO_2023.each do |s|
      funding_method = FundingMethod.find_or_create_by!(
        training_route: s.training_route,
        amount: s.amount,
        funding_type: FUNDING_TYPE_ENUMS[:grant],
        academic_cycle: academic_cycle,
      )
      s.allocation_subjects.map do |subject|
        allocation_subject = AllocationSubject.find_by!(name: subject)
        funding_method.funding_method_subjects.find_or_create_by!(allocation_subject:)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
