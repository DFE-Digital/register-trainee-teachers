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
          record_type: "assessment_only",
          provider: user.provider,
        )
      end

      def user
        @user ||= User.create!(
          first_name: "Tom",
          last_name: "Jones",
          email: "tom@example.com",
          provider: Provider.create!(name: "Provider A"),
        )
      end
    end
  end
end
