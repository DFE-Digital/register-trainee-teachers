# frozen_string_literal: true

class AddFundingRulesFor202627 < ActiveRecord::Migration[7.2]
  def up
    academic_cycle = AcademicCycle.for_year(2026)

    return if academic_cycle.nil?

    BURSARIES_2026_TO_2027.each do |b|
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

    SCHOLARSHIPS_2026_TO_2027.each do |s|
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

    GRANTS_2026_TO_2027.each do |g|
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
    academic_cycle = AcademicCycle.for_year(2026)

    return if academic_cycle.nil?

    FundingMethod.where(academic_cycle:).find_each do |funding_method|
      funding_method.funding_method_subjects.destroy_all
      funding_method.destroy
    end
  end
end
