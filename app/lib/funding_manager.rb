# frozen_string_literal: true

class FundingManager
  BURSARY_TIER_AMOUNTS = {
    tier_one: 5_000,
    tier_two: 4_000,
    tier_three: 2_000,
  }.with_indifferent_access.freeze

  def initialize(trainee)
    @trainee = trainee
    @allocation_subject = trainee.course_allocation_subject
    @academic_cycle = trainee.start_academic_cycle
  end

  def applicable_available_funding
    if can_apply_for_tiered_bursary?
      :grant_and_tiered_bursary
    elsif can_apply_for_grant?
      :grant
    else
      :non_tiered_bursary
    end
  end

  def bursary_amount
    if bursary_tier.present?
      BURSARY_TIER_AMOUNTS[bursary_tier]
    else
      available_bursary_amount
    end
  end

  def scholarship_amount
    available_amount(:scholarship)
  end

  def grant_amount
    available_amount(:grant)
  end

  def can_apply_for_funding_type?
    can_apply_for_bursary? || can_apply_for_scholarship? || can_apply_for_grant?
  end

  def can_apply_for_bursary?
    can_apply_for_tiered_bursary? || available_bursary_amount.present?
  end

  def can_apply_for_tiered_bursary? = trainee.early_years_postgrad?

  def can_apply_for_scholarship?
    scholarship_amount.present?
  end

  def can_apply_for_grant?
    grant_amount.present?
  end

  def funding_available?
    Rails.cache.fetch("FundingManager.funding_available?/#{training_route}/#{academic_cycle&.id}", expires_in: 1.day) do
      funding_methods = academic_cycle.nil? ? FundingMethod.all : academic_cycle.funding_methods
      funding_methods.includes(:funding_method_subjects)
                    .where.not(funding_method_subjects: { id: nil })
                    .where(training_route:).present?
    end
  end

  def allocation_subject_name
    allocation_subject&.name
  end

  def funding_guidance_url
    academic_cycle.label.parameterize
  end

  def funding_guidance_link_text
    "#{academic_cycle.label} (opens a new tab)"
  end

private

  attr_reader :trainee, :academic_cycle, :allocation_subject

  delegate :training_route, :course_subject_one, :bursary_tier, to: :trainee

  def available_bursary_amount
    available_amount(:bursary)
  end

  def available_amount(funding_type)
    return unless allocation_subject && academic_cycle

    @available_amounts ||= {}
    return @available_amounts[funding_type] if @available_amounts.key?(funding_type)

    @available_amounts[funding_type] = allocation_subject.funding_methods.find_by(
      training_route:,
      funding_type:,
      academic_cycle:,
    )&.amount
  end
end
