# frozen_string_literal: true

module Trainees
  module Confirmation
    module PersonalDetails
      class ViewPreview < ViewComponent::Preview
        def default
          render(Trainees::Confirmation::PersonalDetails::View.new(data_model: data_model))
        end

        def with_multiple_nationalities
          trainee.nationalities.concat([Nationality.new(name: "Irish"), Nationality.new(name: "Australian")])
          render(Trainees::Confirmation::PersonalDetails::View.new(data_model: data_model))
        end

      private

        def data_model
          @data_model ||= PersonalDetailsForm.new(trainee)
        end

        def trainee
          @trainee ||= Trainee.new(
            first_names: "Mary",
            last_name: "Campbell",
            date_of_birth: Date.new(1970, 7, 30),
            gender: :other,
            nationalities: [
              Nationality.new(name: "British"),
            ],
          )
        end
      end
    end
  end
end
