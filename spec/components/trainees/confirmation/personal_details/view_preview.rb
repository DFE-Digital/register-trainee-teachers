require "faker"

module Trainees
  module Confirmation
    module PersonalDetails
      class ViewPreview < ViewComponent::Preview
        def default_state
          render_component(Trainees::Confirmation::PersonalDetails::View.new(trainee: trainee))
        end

      private

        def trainee
          @trainee ||= OpenStruct.new(
            first_names: "Mary",
            last_name: "Campbell",
            date_of_birth: Faker::Date.birthday(min_age: 18, max_age: 65),
            gender: "2",
            nationalities: [
              OpenStruct.new(name: "British"),
            ],
          )
        end
      end
    end
  end
end
