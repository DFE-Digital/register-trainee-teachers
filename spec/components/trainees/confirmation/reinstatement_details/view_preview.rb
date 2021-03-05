# frozen_string_literal: true

module Trainees
  module Confirmation
    module ReinstatementDetails
      class ViewPreview < ViewComponent::Preview
        def default
          render(Trainees::Confirmation::ReinstatementDetails::View.new(trainee: trainee))
        end

      private

        def trainee
          @trainee ||= OpenStruct.new({
            reinstate_date: Faker::Date.in_date_period,
          })
        end
      end
    end
  end
end
