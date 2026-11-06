# frozen_string_literal: true

# Funding that depends on the degree or employing school can't be added until
# they're entered (funding_eligibility_step flag). Draft trainees are sent back
# to the draft record, which shows what to complete first.
module FundingPrerequisitesCheckable
  extend ActiveSupport::Concern

  included do
    before_action :check_funding_prerequisites, if: :funding_page?
  end

private

  def funding_page?
    true
  end

  def check_funding_prerequisites
    return unless trainee.draft?

    missing = FundingManager.new(trainee).funding_prerequisites
    return if missing.empty?

    redirect_to(trainee_review_drafts_path(trainee), flash: { funding_prerequisites: missing.map(&:to_s) })
  end
end
