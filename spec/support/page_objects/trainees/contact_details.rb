module PageObjects
  module Trainees
    class ContactDetails < PageObjects::Base
      set_url "/trainees/{id}/contact-details/edit"
      element :locale, ".govuk-radios.locale"
      element :address_line_one, "input[name='trainee[address_line_one]']"
      element :address_line_two, "input[name='trainee[address_line_two]']"
      element :town_city, "input[name='trainee[town_city]']"
      element :postcode, "input[name='trainee[postcode]']"
      element :phone_number, "input[name='trainee[phone_number]']"
      element :email, "input[name='trainee[email]']"
      element :international_address, "input[name='trainee[international_address]']"
      element :submit_button, "input[name='commit']"
    end
  end
end
