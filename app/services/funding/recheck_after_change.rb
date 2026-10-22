# frozen_string_literal: true

module Funding
  # After a draft trainee's degree or employing school changes, the funding is
  # checked again when it depends on that detail (the trainee's funding records
  # are split by it): a completed funding section goes back to in progress, and
  # the draft record and funding confirm page say why until the provider
  # confirms it. Funding that doesn't depend on the change is left as it is.
  class RecheckAfterChange
    include ServicePattern

    CHANGES = %i[degree employing_school].freeze

    def initialize(trainee:, changed:)
      @trainee = trainee
      @changed = changed.to_sym
    end

    def call
      raise(ArgumentError, "unknown change: #{changed}") unless CHANGES.include?(changed)
      return false unless FeatureService.enabled?(:funding_eligibility_step)
      return false unless trainee&.persisted?

      # A fresh copy, so the caller's trainee (and its unsaved changes) isn't touched.
      @trainee = Trainee.find(trainee.id)
      return false unless trainee.draft? && trainee.requires_funding? && funding_started?
      return false unless FundingManager.new(trainee).funding_depends_on?(changed)

      trainee.progress.funding = false
      trainee.progress.public_send("funding_recheck_#{changed}=", true)
      trainee.save!
      true
    end

  private

    attr_reader :trainee, :changed

    def funding_started?
      trainee.progress.funding ||
        ProgressService.call(validator: Funding::FormValidator.new(trainee), progress_value: false).started?
    end
  end
end
