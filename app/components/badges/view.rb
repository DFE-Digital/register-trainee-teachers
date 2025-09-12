# frozen_string_literal: true

module Badges
  class View < ApplicationComponent
    attr_reader :badges

    def initialize(badges:)
      @badges = badges
    end
  end
end
