# frozen_string_literal: true

module PageObjects
  module Trainees
    class ContactDetails < PageObjects::Base
      set_url "/trainees/{id}/contact-details/edit"
      element :uk_locale, "#contact-detail-form-locale-code-uk-field"
      element :non_uk_locale, "#contact-detail-form-locale-code-non-uk-field"
      element :address_line_one, "#contact-detail-form-address-line-one-field"
      element :address_line_two, "#contact-detail-form-address-line-two-field"
      element :town_city, "#contact-detail-form-town-city-field"
      element :postcode, "#contact-detail-form-postcode-field"
      element :email, "#contact-detail-form-email-field"
      element :international_address, "#contact-detail-form-international-address-field"
      element :submit_button, "input[name='commit']"
    end
  end
end
