# frozen_string_literal: true

module Trainees
  module DeferralDetails
    class ViewPreview < ViewComponent::Preview
      def default
        render(Trainees::DeferralDetails::View.new(trainee))
      end

    private

      def trainee
        @trainee ||= Trainee.new(id: 1,
                                 defer_date: Time.zone.yesterday)
      end
    end
  end
end
