module PageObjects
  module Trainees
    class ContactDetails < PageObjects::Base
      set_url "/trainees/{id}/contact-details/edit"
      element :uk_locale, "#trainee-locale-code-uk-field"
      element :non_uk_locale, "#trainee-locale-code-non-uk-field"
      element :address_line_one, "#trainee-address-line-one-field"
      element :address_line_two, "#trainee-address-line-two-field"
      element :town_city, "#trainee-town-city-field"
      element :postcode, "#trainee-postcode-field"
      element :phone_number, "#trainee-phone-number-field"
      element :email, "#trainee-email-field"
      element :international_address, "#trainee-international-address-field"
      element :submit_button, "input[name='commit']"
    end
  end
end
