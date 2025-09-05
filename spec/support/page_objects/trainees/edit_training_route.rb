# frozen_string_literal: true

module PageObjects
  module Trainees
    class EditTrainingRoute < PageObjects::Base
      include PageObjects::Helpers

      class TrainingRouteOptions < SitePrism::Section
        element :input, "input"
        element :label, "label"
      end

      set_url "/trainees/{id}/training-routes/edit"

      element :page_heading, ".govuk-heading-xl"

      element :assessment_only, "#training-routes-form-training-route-assessment-only-field"

      element :provider_led_postgrad, "#training-routes-form-training-route-provider-led-postgrad-field"

      element :school_direct_salaried, "#training-routes-form-training-route-school-direct-salaried-field"

      element :early_years_postgrad, "#training-routes-form-training-route-early-years-postgrad-field"

      element :pg_teaching_apprenticeship, "#training-routes-form-training-route-pg-teaching-apprenticeship-field"

      sections :training_route_options, TrainingRouteOptions, ".govuk-radios__item"

      element :continue_button, 'button.govuk-button[type="submit"]'
    end
  end
end
