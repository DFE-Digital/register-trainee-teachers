# frozen_string_literal: true

module TabNavigation
  class View < ComponentBase
    attr_reader :items

    def initialize(items:)
      @items = items&.compact
    end
  end
end
