module Trainees
  module Confirmation
    module PersonalDetails
      class View < GovukComponent::Base
        attr_accessor :trainee

        def initialize(trainee:)
          @trainee = trainee
        end

        def full_name
          return I18n.t("confirmation.not_entered") unless trainee.first_names

          "#{trainee.first_names} #{trainee.last_name}".upcase
        end

        def date_of_birth
          return I18n.t("confirmation.not_entered") unless trainee.date_of_birth

          trainee.date_of_birth.strftime("%-d %B %Y")
        end

        def gender
          return I18n.t("confirmation.not_entered") unless trainee.gender

          # TODO: This will change once we have set up gender to use ENUM values.
          gender_map = {
            "1" => "Male",
            "2" => "Female",
            "3" => "Other",
          }

          gender_map[trainee.gender]
        end

        def nationality
          return I18n.t("confirmation.not_entered") if trainee.nationalities.blank?

          trainee.nationalities.map { |nationality| nationality.name.titleize }.join(", ")
        end
      end
    end
  end
end
