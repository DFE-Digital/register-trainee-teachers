# frozen_string_literal: true

require "govuk/components"

module Trainees
  module Timeline
    class ViewPreview < ViewComponent::Preview
      def created
        render Trainees::Timeline::View.new(trainee)
      end

      def submitted_for_trn
        trainee.submit_for_trn!
        render Trainees::Timeline::View.new(trainee)
      end

    private

      def trainee
        @trainee ||= Trainee.create!(
          training_route: TRAINING_ROUTE_ENUMS[:assessment_only],
          provider: user.provider,
        )
      end

      def user
        @user ||= User.create!(
          first_name: "Tom",
          last_name: "Jones",
          email: "tom@example.com",
          dttp_id: "1b5f121c-3e8b-4773-8560-5539fa93a5c8",
          provider: Provider.create!(name: "Provider A", dttp_id: "b77c821a-c12a-4133-8036-6ef1db146f9e", code: "AB1"),
        )
      end
    end
  end
end
