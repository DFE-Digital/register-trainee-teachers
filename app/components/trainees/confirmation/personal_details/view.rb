module Trainees
  module Confirmation
    module PersonalDetails
      class View < GovukComponent::Base
        attr_accessor :trainee, :not_provided_copy

        def initialize(trainee:)
          @trainee = trainee
          @not_provided_copy = I18n.t("components.confirmation.not_provided")
        end

        def full_name
          return not_provided_copy unless trainee.first_names && trainee.last_name

          "#{trainee.first_names} #{trainee.middle_names} #{trainee.last_name}".upcase
        end

        def date_of_birth
          return not_provided_copy unless trainee.date_of_birth

          trainee.date_of_birth.strftime("%-d %B %Y")
        end

        def gender
          return not_provided_copy unless trainee.gender

          # TODO: This will change once we have set up gender to use ENUM values.
          gender_map = {
            "1" => "Male",
            "2" => "Female",
            "3" => "Other",
          }

          gender_map[trainee.gender]
        end

        def nationality
          return not_provided_copy if trainee.nationalities.blank?

          trainee.nationalities.map { |nationality| nationality.name.titleize }.join(", ")
        end
      end
    end
  end
end
