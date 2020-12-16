# frozen_string_literal: true

module Trainees
  module Confirmation
    module WithdrawalDetails
      class ViewPreview < ViewComponent::Preview
        def default
          render(Trainees::Confirmation::WithdrawalDetails::View.new(trainee: trainee))
        end

      private

        def trainee
          @trainee ||= OpenStruct.new({
            withdraw_date: Faker::Date.in_date_period,
            withdraw_reason: WithdrawalReasons::SPECIFIC.sample,
          })
        end
      end
    end
  end
end
