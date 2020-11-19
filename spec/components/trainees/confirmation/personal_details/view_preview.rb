# frozen_string_literal: true

module Trainees
  module Confirmation
    module PersonalDetails
      class ViewPreview < ViewComponent::Preview
        def default
          render_component(Trainees::Confirmation::PersonalDetails::View.new(trainee: trainee))
        end

        def with_multiple_nationalities
          trainee.nationalities.push(OpenStruct.new(name: "Irish")).push(OpenStruct.new(name: "Australian"))
          render_component(Trainees::Confirmation::PersonalDetails::View.new(trainee: trainee))
        end

      private

        def trainee
          @trainee ||= OpenStruct.new(
            first_names: "Mary",
            last_name: "Campbell",
            date_of_birth: Date.new(1970, 7, 30),
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
