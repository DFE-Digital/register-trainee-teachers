# frozen_string_literal: true

require "govuk/components"
module Trainees
  module Confirmation
    module ContactDetails
      class ViewPreview < ViewComponent::Preview
        def with_uk_address
          mock_trainee.locale_code = "uk"
          render(Trainees::Confirmation::ContactDetails::View.new(trainee: mock_trainee))
        end

        def with_non_uk_address
          mock_trainee.locale_code = "non_uk"
          mock_trainee.email = "visit@paris.com"
          render(Trainees::Confirmation::ContactDetails::View.new(trainee: mock_trainee))
        end

        def with_no_data
          render(Trainees::Confirmation::ContactDetails::View.new(trainee: Trainee.new(id: 2)))
        end

      private

        def mock_trainee
          @mock_trainee ||= Trainee.new(
            id: 1,
            international_address: "Champ de Mars\r\n5 Avenue Anatole France\r\n75007 Paris\r\nFrance",
            address_line_one: "32 Windsor Gardens",
            address_line_two: "Westminster",
            town_city: "London",
            postcode: "EC1 9CP",
            email: "Paddington@bear.com",
          )
        end
      end
    end
  end
end
