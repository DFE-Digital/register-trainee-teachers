# frozen_string_literal: true

class FixFundingMethodsFor20192020 < ActiveRecord::Migration[6.1]
  UNDERGRAD_BURSARIES = [
    OpenStruct.new(
      training_route: ReferenceData::TRAINING_ROUTES.provider_led_undergrad.name,
      amount: 9_000,
      allocation_subjects: [
        AllocationSubjects::MATHEMATICS,
        AllocationSubjects::PHYSICS,
      ],
    ),
    OpenStruct.new(
      training_route: ReferenceData::TRAINING_ROUTES.opt_in_undergrad.name,
      amount: 9_000,
      allocation_subjects: [
        AllocationSubjects::MATHEMATICS,
        AllocationSubjects::PHYSICS,
        AllocationSubjects::COMPUTING,
        AllocationSubjects::MODERN_LANGUAGES,
      ],
    ),
  ].freeze

  def up
    # i.e. the academic cycle 2019/20
    academic_cycle = AcademicCycle.for_year(2019)
    undergrad_routes = %w[provider_led_undergrad opt_in_undergrad]

    incorrect_funding_methods = academic_cycle.funding_methods.where(training_route: undergrad_routes)
    incorrect_funding_methods.destroy_all

    UNDERGRAD_BURSARIES.each do |bursary|
      b = FundingMethod.find_or_create_by!(
        training_route: bursary.training_route,
        amount: bursary.amount,
        academic_cycle: academic_cycle,
        funding_type: FUNDING_TYPE_ENUMS[:bursary],
      )
      bursary.allocation_subjects.map do |subject|
        allocation_subject = AllocationSubject.find_by!(name: subject)
        b.funding_method_subjects.find_or_create_by!(allocation_subject:)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
