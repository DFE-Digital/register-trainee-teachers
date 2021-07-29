# frozen_string_literal: true

module ApplyApplications
  module ReviewSummary
    class View < GovukComponent::Base
      renders_one :header

      def initialize(has_errors:, trainee:)
        @has_errors = has_errors
        @invalid_data_view = ApplyInvalidDataView.new(trainee.apply_application)
      end

      def render?
        invalid_data_view.invalid_data?
      end

      def summary_component
        @summary_component ||= has_errors ? ErrorSummary::View : InformationSummary::View
      end

    private

      attr_reader :invalid_data_view, :has_errors
    end
  end
end
