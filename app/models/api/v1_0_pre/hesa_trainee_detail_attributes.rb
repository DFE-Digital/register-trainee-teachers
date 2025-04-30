# frozen_string_literal: true

module Api
  module V10Pre
    class HesaTraineeDetailAttributes < Api::V01::HesaTraineeDetailAttributes
      validates_with RulesValidator

      include Api::ErrorAttributeAdapter
      attr_accessor :record_source

      def initialize(params, record_source:)
        super(params)
        self.record_source = record_source
      end
    end
  end
end
