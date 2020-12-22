# frozen_string_literal: true

module Trainees
  module Confirmation
    module DeferralDetails
      class ViewPreview < ViewComponent::Preview
        def default
          render(Trainees::Confirmation::DeferralDetails::View.new(trainee: trainee))
        end

      private

        def trainee
          @trainee ||= OpenStruct.new({
            withdraw_date: Faker::Date.in_date_period,
          })
        end
      end
    end
  end
end
