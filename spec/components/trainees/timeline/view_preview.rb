# frozen_string_literal: true

require "govuk/components"

module Trainees
  module Timeline
    class ViewPreview < ViewComponent::Preview
      def created
        render Trainees::Timeline::View.new(trainee)
      end

      def submitted_for_trn
        render Trainees::Timeline::View.new(
          trainee(submitted_for_trn_at: Time.zone.today),
        )
      end

    private

      def trainee(attrs = {})
        Trainee.new(
          provider: user.provider,
          created_at: Time.zone.yesterday,
          **attrs,
        )
      end

      def user
        @user ||= User.create!(
          first_name: "Tom",
          last_name: "Jones",
          email: "tom@example.com",
          provider: Provider.create(name: "Provider A"),
        )
      end
    end
  end
end
