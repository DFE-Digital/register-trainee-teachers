# frozen_string_literal: true

module Badges
  class View < GovukComponent::Base
    attr_reader :state_counts

    def initialize(state_counts)
      @state_counts = state_counts
    end
  end
end
