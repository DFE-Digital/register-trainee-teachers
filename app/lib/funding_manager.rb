# frozen_string_literal: true

class FundingManager
  BURSARY_TIER_AMOUNTS = {
    tier_one: 5000,
    tier_two: 4000,
    tier_three: 2000,
  }.with_indifferent_access.freeze

  def initialize(trainee)
    @trainee = trainee
  end

  def bursary_amount
    if bursary_tier.present?
      BURSARY_TIER_AMOUNTS[bursary_tier]
    else
      available_bursary_amount
    end
  end

  def can_apply_for_bursary?
    training_route == TRAINING_ROUTE_ENUMS[:early_years_postgrad] || available_bursary_amount.present?
  end

  def funding_available?
    FundingMethod.includes(:funding_method_subjects).where.not(funding_method_subjects: { id: nil })
      .where(training_route: training_route).present?
  end

private

  attr_reader :trainee

  delegate :training_route, :course_subject_one, :bursary_tier, to: :trainee

  def available_bursary_amount
    available_amount(:bursary)
  end

  def available_scholarship_amount
    available_amount(:scholarship)
  end
  
  def available_amount(funding_type)
    if (allocation_subject = SubjectSpecialism.find_by(name: course_subject_one)&.allocation_subject)
      allocation_subject.funding_methods.find_by(training_route: training_route, funding_type: funding_type)&.amount
    end
  end
end
