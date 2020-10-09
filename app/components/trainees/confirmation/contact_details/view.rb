module Trainees
  module Confirmation
    module ContactDetails
      class View < GovukComponent::Base
        include SanitizeHelper

        attr_accessor :trainee

        def initialize(trainee:)
          @trainee = trainee
          @not_provided_copy = I18n.t("components.confirmation.not_provided")
        end

        def address
          return @not_provided_copy if trainee.locale_code.nil? || (uk_address.blank? && international_address.blank?)

          sanitize(trainee.uk? ? uk_address : international_address)
        end

        def email
          return @not_provided_copy if trainee.email.blank?

          trainee.email
        end

        def phone_number
          return @not_provided_copy if trainee.phone_number.blank?

          trainee.phone_number
        end

      private

        def uk_address
          [trainee.address_line_one,
           trainee.address_line_two,
           trainee.town_city,
           trainee.postcode].reject(&:blank?).join(tag.br)
        end

        def international_address
          trainee.international_address
            .split(/\r\n+/)
            .reject(&:blank?)
            .join(tag.br)
        end
      end
    end
  end
end
