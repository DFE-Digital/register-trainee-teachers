# frozen_string_literal: true

module Badges
  class View < ComponentBase
    attr_reader :badges

    def initialize(badges:)
      @badges = badges
    end
  end
end
