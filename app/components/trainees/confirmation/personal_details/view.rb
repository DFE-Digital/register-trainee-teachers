# frozen_string_literal: true

module Trainees
  module Confirmation
    module PersonalDetails
      class View < GovukComponent::Base
        include SanitizeHelper

        attr_accessor :form_model

        def initialize(form_model:)
          @form_model = form_model
          @nationalities = fetch_nationalities
          @not_provided_copy = I18n.t("components.confirmation.not_provided")
        end

        def full_name
          return @not_provided_copy unless form_model.first_names && form_model.last_name

          "#{form_model.first_names} #{form_model.middle_names} #{form_model.last_name}"
        end

        def date_of_birth
          return @not_provided_copy unless form_model.date_of_birth

          form_model.date_of_birth.strftime("%-d %B %Y")
        end

        def gender
          return @not_provided_copy unless form_model.gender

          I18n.t("components.confirmation.personal_detail.gender.#{form_model.gender}")
        end

        def nationality
          return @not_provided_copy if nationalities.blank?

          if nationalities.size == 1
            nationalities.first.name.titleize
          else
            nationality_names = nationalities.map { |nationality| nationality.name.titleize }
            sanitize(tag.ul(class: "govuk-list") do
              nationality_names.each do |nationality_name|
                concat tag.li(nationality_name)
              end
            end)
          end
        end

      private

        attr_reader :nationalities

        def fetch_nationalities
          Nationality.where(id: form_model.nationality_ids)
        end
      end
    end
  end
end
