# frozen_string_literal: true

module Confirmation
  module PersonalDetails
    class ViewPreview < ViewComponent::Preview
      def default
        render(View.new(data_model: trainee))
      end

      def with_multiple_nationalities
        trainee.nationalities.concat([Nationality.new(name: "Irish"), Nationality.new(name: "Australian")])
        render(View.new(data_model: trainee))
      end

    private

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
