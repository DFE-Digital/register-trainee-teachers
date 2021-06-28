# frozen_string_literal: true

module PageObjects
  module Trainees
    class ContactDetails < PageObjects::Base
      set_url "/trainees/{id}/contact-details/edit"
      element :uk_locale, "#contact-details-form-locale-code-uk-field"
      element :non_uk_locale, "#contact-details-form-locale-code-non-uk-field"
      element :address_line_one, "#contact-details-form-address-line-one-field"
      element :address_line_two, "#contact-details-form-address-line-two-field"
      element :town_city, "#contact-details-form-town-city-field"
      element :postcode, "#contact-details-form-postcode-field"
      element :email, "#contact-details-form-email-field"
      element :international_address, "#contact-details-form-international-address-field"
      element :submit_button, "button[type='submit']"
    end
  end
end
