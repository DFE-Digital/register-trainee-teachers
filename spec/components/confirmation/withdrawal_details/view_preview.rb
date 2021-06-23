# frozen_string_literal: true

module Confirmation
  module WithdrawalDetails
    class ViewPreview < ViewComponent::Preview
      def default
        render(View.new(data_model))
      end

    private

      def data_model
        OpenStruct.new(
          trainee: Trainee.new(id: 1),
          date: Faker::Date.in_date_period,
          withdraw_reason: WithdrawalReasons::SPECIFIC.sample,
        )
      end
    end
  end
end
