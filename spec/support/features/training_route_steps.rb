# frozen_string_literal: true

module Features
  module TrainingRouteSteps
    def given_i_have_created_a_provider_led_trainee
      trainee_index_page.load
      trainee_index_page.add_trainee_link.click
      new_trainee_page.provider_led_postgrad.click
      new_trainee_page.continue_button.click
    end
  end
end
