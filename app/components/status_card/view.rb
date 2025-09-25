# frozen_string_literal: true

module StatusCard
  class View < ApplicationComponent
    attr_reader :status_colour, :count, :state_name, :target

    def initialize(status_colour:, count:, state_name:, target:)
      @status_colour = status_colour
      @count = count
      @state_name = state_name
      @target = target
    end
  end
end
