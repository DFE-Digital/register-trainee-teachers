# frozen_string_literal: true

module Api
  module Rules
    class Base
      include ServicePattern

      class << self
        alias_method :valid?, :call
      end
    end
  end
end
