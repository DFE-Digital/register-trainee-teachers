# frozen_string_literal: true

module PageObjects
  module Trainees
    class New < PageObjects::Base
      set_url "/trainees/new"

      element :page_heading, ".govuk-heading-xl"

      element :assessment_only, "#trainee-training-route-assessment-only-field"

      element :provider_led, "#trainee-training-route-provider-led-field"
      
      element :other, "#trainee-training-route-other-field"

      element :continue_button, 'input.govuk-button[type="submit"]'
    end
  end
end
