# frozen_string_literal: true

require "govuk/components"

module Trainees
  module SchoolDetails
    class ViewPreview < ViewComponent::Preview
      def default
        render(View.new(mock_trainee(with_employing: true)))
      end

      def with_only_one_school
        render(View.new(mock_trainee))
      end

    private

      def mock_trainee(with_employing: false)
        @mock_trainee ||= Trainee.new(
          id: 1,
          lead_school: mock_school(lead: true),
          employing_school: with_employing ? mock_school : nil,
        )
      end

      def mock_school(lead: false)
        @mock_school ||= School.new(
          id: 1,
          urn: "12345",
          name: "Test School",
          postcode: "E1 5DJ",
          town: "London",
          open_date: Time.zone.today,
          lead_school: lead,
        )
      end
    end
  end
end
