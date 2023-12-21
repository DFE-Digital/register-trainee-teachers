# frozen_string_literal: true

module Badges
  class View < ViewComponent::Base
    attr_reader :badges

    def initialize(badges:)
      @badges = badges
    end
  end
end
