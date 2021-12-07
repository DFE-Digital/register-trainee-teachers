# frozen_string_literal: true

class SeedAcademicCyclesFor20212022 < ActiveRecord::Migration[6.1]
  def up
    SEED_BURSARIES.each do |b|
      bursary = FundingMethod.find_or_create_by!(training_route: b.training_route, amount: b.amount, academic_cycle_id: b.academic_cycle_id)
      bursary.funding_type = :bursary
      bursary.save!
      b.allocation_subjects.map do |subject|
        allocation_subject = AllocationSubject.find_by!(name: subject)
        bursary.funding_method_subjects.find_or_create_by!(allocation_subject: allocation_subject)
      end
    end

    SEED_SCHOLARSHIPS.each do |s|
      funding_method = FundingMethod.find_or_create_by!(
        training_route: s.training_route,
        amount: s.amount,
        funding_type: FUNDING_TYPE_ENUMS[:scholarship],
        academic_cycle_id: s.academic_cycle_id,
      )
      s.allocation_subjects.map do |subject|
        allocation_subject = AllocationSubject.find_by!(name: subject)
        funding_method.funding_method_subjects.find_or_create_by!(allocation_subject: allocation_subject)
      end
    end

    SEED_GRANTS.each do |s|
      funding_method = FundingMethod.find_or_create_by!(
        training_route: s.training_route,
        amount: s.amount,
        funding_type: FUNDING_TYPE_ENUMS[:grant],
        academic_cycle_id: s.academic_cycle_id,
      )
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
