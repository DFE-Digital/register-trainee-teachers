module Trainees
  module Confirmation
    module PersonalDetails
      class View < GovukComponent::Base
        include SanitizeHelper

        attr_accessor :trainee

        def initialize(trainee:)
          @trainee = trainee
          @not_provided_copy = I18n.t("components.confirmation.not_provided")
        end

        def full_name
          return @not_provided_copy unless trainee.first_names && trainee.last_name

          "#{trainee.first_names} #{trainee.middle_names} #{trainee.last_name}".upcase
        end

        def date_of_birth
          return @not_provided_copy unless trainee.date_of_birth

          trainee.date_of_birth.strftime("%-d %B %Y")
        end

        def gender
          return @not_provided_copy unless trainee.gender

          trainee.gender.capitalize
        end

        def nationality
          return @not_provided_copy if trainee.nationalities.blank?

          if trainee.nationalities.size == 1
            trainee.nationalities.first.name.titleize
          else
            nationalities = trainee.nationalities.map { |nationality| nationality.name.titleize }
            sanitize(tag.ul(class: "govuk-list") do
              nationalities.each do |nationality|
                concat tag.li(nationality)
              end
            end)
          end
        end
      end
    end
  end
end
