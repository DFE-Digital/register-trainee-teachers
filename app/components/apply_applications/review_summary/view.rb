# frozen_string_literal: true

module ApplyApplications
  module ReviewSummary
    class View < GovukComponent::Base
      renders_one :header

      def initialize(form:, trainee:)
        @has_errors = form.errors.any?
        @form = form
        @trainee = trainee
        @invalid_data_view = ApplyInvalidDataView.new(trainee.apply_application)
      end

      def render?
        errors_captured? || invalid_data_exists?
      end

      def summary_component
        @summary_component ||= errors_captured? ? ErrorSummary::View : InformationSummary::View
      end

    private

      def invalid_data_exists?
        form_is_valid = form.valid?

        form.errors.clear unless errors_captured?

        !form_is_valid && invalid_data_view.invalid_data?
      end

      def errors_captured?
        @has_errors
      end

      attr_reader :invalid_data_view, :form
    end
  end
end
