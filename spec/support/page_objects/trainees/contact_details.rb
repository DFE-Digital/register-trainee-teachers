module PageObjects
  module Trainees
    class ContactDetails < PageObjects::Base
      set_url "/trainees/{id}/contact-details/edit"
      element :uk_locale, "#contact-detail-locale-code-uk-field"
      element :non_uk_locale, "#contact-detail-locale-code-non-uk-field"
      element :address_line_one, "#contact-detail-address-line-one-field"
      element :address_line_two, "#contact-detail-address-line-two-field"
      element :town_city, "#contact-detail-town-city-field"
      element :postcode, "#contact-detail-postcode-field"
      element :phone_number, "#contact-detail-phone-number-field"
      element :email, "#contact-detail-email-field"
      element :international_address, "#contact-detail-international-address-field"
      element :submit_button, "input[name='commit']"
    end
  end
end
