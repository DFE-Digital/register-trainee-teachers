module Confirmation
  class Trainees::Confirmation::ContactDetails::View < GovukComponent::Base
    attr_accessor :trainee

    delegate :phone_number, :email, to: :trainee

    def initialize(trainee:)
      @trainee = trainee
    end

    def address
      uk_locale? ? uk_address : international_address
    end

  private

    def uk_locale?
      trainee.locale_code == "uk"
    end

    def uk_address
      "#{trainee.address_line_one}, #{trainee.address_line_two}, #{trainee.town_city}, #{trainee.postcode}"
    end

    def international_address
      trainee.international_address
    end
  end
end
