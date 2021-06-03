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

    def initialize(trainees)
      @trainees = trainees
      populate_state_counts!
    end

    def full_width_states
      @counts.slice(*FULL_WIDTH_STATES)
    end

    def narrow_states
      @counts.slice(*NARROW_STATES)
    end

    def populate_state_counts!
      defaults = Trainee.states.keys.index_with do |state|
        [state, 0]
      end

      counts = @trainees.group(:state).count.reverse_merge(defaults)

      if eyts_trainees? == qts_trainees?
        counts["awarded"] ||= 0
        counts["recommended_for_award"] ||= 0
      elsif eyts_trainees?
        awarded = counts.delete("awarded")
        counts["eyts_received"] = awarded

        recommended = counts.delete("recommended_for_award")
        counts["eyts_recommended"] = recommended
      elsif qts_trainees?
        awarded = counts.delete("awarded")
        counts["qts_received"] = awarded

        recommended = counts.delete("recommended_for_award")
        counts["qts_recommended"] = recommended
      end

      @counts = counts
    end

    def eyts_trainees?
      return @_eyts_trainees if defined?(@_eyts_trainees)

      @_eyts_trainees =
        @trainees.where(training_route: EARLY_YEARS_ROUTES, state: %i[awarded recommended_for_award]).count.positive?
    end

    def qts_trainees?
      return @_qts_trainees if defined?(@_qts_trainees)

      @_qts_trainees =
        @trainees.where(state: %i[awarded recommended_for_award]).where.not(training_route: EARLY_YEARS_ROUTES).count.positive?
    end
  end
end
