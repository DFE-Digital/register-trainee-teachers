# frozen_string_literal: true

module Confirmation
  module ReinstatementDetails
    class ViewPreview < ViewComponent::Preview
      def default
        render(View.new(data_model))
      end

    private

      def data_model
        trainee = OpenStruct.new(id: 1, reinstate_date: Faker::Date.in_date_period)
        OpenStruct.new(trainee: trainee, date: trainee.reinstate_date)
      end
    end
  end
end
