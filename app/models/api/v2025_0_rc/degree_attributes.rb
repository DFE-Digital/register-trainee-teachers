# frozen_string_literal: true

module Api
  module V20250Rc
    class DegreeAttributes < Api::V01::DegreeAttributes
      include Api::ErrorAttributeAdapter
      attr_accessor :record_source

      def initialize(params, trainee: nil, record_source: nil)
        super(params, trainee:)
        self.record_source = record_source
      end
    end
  end
end
