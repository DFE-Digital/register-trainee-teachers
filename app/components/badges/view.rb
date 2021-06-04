# frozen_string_literal: true

module Badges
  class View < GovukComponent::Base
    FULL_WIDTH_STATES = %w[
      draft
      submitted_for_trn
      trn_received
    ].freeze

    NARROW_STATES = %w[
      recommended_for_award
      awarded
      eyts_recommended
      eyts_received
      qts_recommended
      qts_received
      deferred
      withdrawn
    ].freeze

    def initialize(state_counts)
      @state_counts = state_counts
    end

    def full_width_states
      @state_counts.slice(*FULL_WIDTH_STATES)
    end

    def narrow_states
      @state_counts.slice(*NARROW_STATES)
    end
  end
end
