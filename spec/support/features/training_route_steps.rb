# frozen_string_literal: true

module Features
  module TrainingRouteSteps
    def given_i_have_created_a_provider_led_trainee
      choose_training_route_for(TRAINING_ROUTE_ENUMS[:provider_led_postgrad])
    end

    def given_i_have_created_an_assessment_only_trainee
      choose_training_route_for(TRAINING_ROUTE_ENUMS[:assessment_only])
    end

    def given_i_have_created_a_school_direct_salaried_trainee
      choose_training_route_for(TRAINING_ROUTE_ENUMS[:school_direct_salaried])
    end

    def given_i_have_created_a_school_direct_tuition_fee_trainee
      choose_training_route_for(TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee])
    end

  private

    def choose_training_route_for(route)
      trainee_index_page.load
      trainee_index_page.add_trainee_link.click
      new_trainee_page.public_send(route).click
      new_trainee_page.continue_button.click
    end
  end
end
