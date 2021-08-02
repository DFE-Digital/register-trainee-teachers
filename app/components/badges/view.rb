# frozen_string_literal: true

module Badges
  class View < GovukComponent::Base
    attr_reader :state_counts

    def initialize(state_counts)
      @state_counts = state_counts
    end

    def map_state_to_filter_params(state)
      case state
      when "awarded"
        %w[eyts_awarded qts_awarded]
      when "recommended_for_award"
        %w[eyts_recommended qts_recommended]
      else
        [state]
      end
    end
  end
end
