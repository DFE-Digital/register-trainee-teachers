# frozen_string_literal: true

module Trainees
  module DeferralDetails
    class ViewPreview < ViewComponent::Preview
      def default
        render(Trainees::DeferralDetails::View.new(data_model))
      end

    private

      def data_model
        trainee = Trainee.new(id: 1, defer_date: Time.zone.yesterday)
        OpenStruct.new(trainee: trainee, date: trainee.defer_date)
      end
    end
  end
end
