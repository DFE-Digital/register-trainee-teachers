# frozen_string_literal: true

module Funding
  # After the trainee's degrees change, clears a funding choice that funding
  # management marks "not available" for an unrelated degree (for example a
  # bursary only for a relevant degree), and marks the funding section
  # incomplete so the provider chooses again.
  class ClearUnavailableForDegree
    include ServicePattern

    CHOICES = {
      "bursary" => :applying_for_bursary,
      "scholarship" => :applying_for_scholarship,
      "grant" => :applying_for_grant,
    }.freeze

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      return false unless trainee&.persisted?
      return false unless CHOICES.values.any? { |choice| trainee.public_send(choice) }

      # A fresh copy, so the caller's trainee (and its unsaved changes) isn't touched.
      @trainee = Trainee.find(trainee.id)
      unavailable = FundingManager.new(trainee).unavailable_for_degree_types
      return false if unavailable.none? { |funding_type| trainee.public_send(CHOICES.fetch(funding_type)) }

      trainee.progress.funding = false
      trainee.update!(applying_for_bursary: nil, applying_for_scholarship: nil, applying_for_grant: nil, bursary_tier: nil)
      true
    end

  private

    attr_reader :trainee
  end
end
