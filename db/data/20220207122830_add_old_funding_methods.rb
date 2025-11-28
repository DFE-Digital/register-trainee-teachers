# frozen_string_literal: true

class AddOldFundingMethods < ActiveRecord::Migration[6.1]
  ACADEMIC_CYCLE = AcademicCycle.find_by(start_date: "2019-09-01")

  BURSARIES_2019 = [
    OpenStruct.new(
      amount: 26_000,
      allocation_subjects: [
        AllocationSubjects::PHYSICS,
        AllocationSubjects::COMPUTING,
        AllocationSubjects::MODERN_LANGUAGES,
        AllocationSubjects::GEOGRAPHY,
        AllocationSubjects::CHEMISTRY,
        AllocationSubjects::CLASSICS,
        AllocationSubjects::BIOLOGY,
      ],
    ),
    OpenStruct.new(
      amount: 20_000,
      allocation_subjects: [
        AllocationSubjects::MATHEMATICS,
      ],
    ),
    OpenStruct.new(
      amount: 15_000,
      allocation_subjects: [
        AllocationSubjects::ENGLISH,
      ],
    ),
    OpenStruct.new(
      amount: 12_000,
      allocation_subjects: [
        AllocationSubjects::DESIGN_AND_TECHNOLOGY,
        AllocationSubjects::HISTORY,
      ],
    ),
    OpenStruct.new(
      amount: 9_000,
      allocation_subjects: [
        AllocationSubjects::RELIGIOUS_EDUCATION,
        AllocationSubjects::MUSIC,
      ],
    ),
    OpenStruct.new(
      amount: 6_000,
      allocation_subjects: [
        AllocationSubjects::PRIMARY_WITH_MATHEMATICS,
      ],
    ),
  ].freeze

  SCHOLARSHIPS_2019 = [
    OpenStruct.new(
      amount: 28_000,
      allocation_subjects: [
        AllocationSubjects::PHYSICS,
        AllocationSubjects::COMPUTING,
        AllocationSubjects::MODERN_LANGUAGES,
        AllocationSubjects::GEOGRAPHY,
        AllocationSubjects::CHEMISTRY,
      ],
    ),
    OpenStruct.new(
      amount: 22_000,
      allocation_subjects: [
        AllocationSubjects::MATHEMATICS,
      ],
    ),
  ].freeze

  def up
    ReferenceData::TRAINING_ROUTES.names.each do |route|
      BURSARIES_2019.each do |bursary|
        b = FundingMethod.find_or_create_by!(
          training_route: route,
          amount: bursary.amount,
          academic_cycle: ACADEMIC_CYCLE,
          funding_type: FUNDING_TYPE_ENUMS[:bursary],
        )
        bursary.allocation_subjects.map do |subject|
          allocation_subject = AllocationSubject.find_by!(name: subject)
          b.funding_method_subjects.find_or_create_by!(allocation_subject:)
        end
      end

      SCHOLARSHIPS_2019.each do |scholarship|
        s = FundingMethod.find_or_create_by!(
          training_route: route,
          amount: scholarship.amount,
          funding_type: FUNDING_TYPE_ENUMS[:scholarship],
          academic_cycle: ACADEMIC_CYCLE,
        )
        scholarship.allocation_subjects.map do |subject|
          allocation_subject = AllocationSubject.find_by!(name: subject)
          s.funding_method_subjects.find_or_create_by!(allocation_subject:)
        end
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
