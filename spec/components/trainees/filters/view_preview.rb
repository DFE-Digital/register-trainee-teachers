# frozen_string_literal: true

require "govuk/components"
module Trainees
  module Filters
    class ViewPreview < ViewComponent::Preview
      def default_view
        render Trainees::Filters::View.new(filters: filter_mock)
      end

    private

      def filter_mock
        ActionController::Parameters.new({
          record_type: %w[assessment_only],
          subject: "Biology",
        }).permit(:subject, :text_search, record_type: [], state: [])
      end
    end
  end
end
