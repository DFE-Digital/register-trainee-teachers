# frozen_string_literal: true

module Api
  module UpdateDegreeService
    class V01
      include ServicePattern

      def initialize(degree:, attributes:)
        @degree = degree
        @attributes = attributes
      end

      def call
        if @attributes.valid?
          [@degree.update(@attributes.attributes), @degree.errors&.full_messages]
        else
          [false, @attributes.errors.full_messages]
        end
      end
    end
  end
end
