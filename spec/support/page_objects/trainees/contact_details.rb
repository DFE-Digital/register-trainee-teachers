# frozen_string_literal: true

module PageObjects
  module Trainees
    class ContactDetails < PageObjects::Base
      set_url "/trainees/{id}/contact-details/edit"
      element :email, "#contact-details-form-email-field"
      element :submit_button, "button[type='submit']"
    end
  end
end
