# frozen_string_literal: true

module Features
  module TrainingRouteSteps
    def given_i_have_created_a_provider_led_trainee
      choose_training_route_for(ReferenceData::TRAINING_ROUTES.provider_led_postgrad.name)
    end

    def given_i_have_created_a_provider_led_undergrad_trainee
      choose_training_route_for(ReferenceData::TRAINING_ROUTES.provider_led_undergrad.name)
    end

    def given_i_have_created_an_assessment_only_trainee
      choose_training_route_for(ReferenceData::TRAINING_ROUTES.assessment_only.name)
    end

    def given_i_have_created_a_teach_first_trainee
      choose_training_route_for(ReferenceData::TRAINING_ROUTES.hpitt_postgrad.name)
    end

    def given_i_have_created_a_school_direct_salaried_trainee
      choose_training_route_for(ReferenceData::TRAINING_ROUTES.school_direct_salaried.name)
    end

    def given_i_have_created_a_school_direct_tuition_fee_trainee
      choose_training_route_for(ReferenceData::TRAINING_ROUTES.school_direct_tuition_fee.name)
    end

    def given_i_have_created_an_early_years_assessment_only_trainee
      choose_training_route_for(ReferenceData::TRAINING_ROUTES.early_years_assessment_only.name)
    end

    def given_i_have_created_an_early_years_postgrad_trainee
      choose_training_route_for(ReferenceData::TRAINING_ROUTES.early_years_postgrad.name)
    end

    def given_i_have_created_an_early_years_salaried_trainee
      choose_training_route_for(ReferenceData::TRAINING_ROUTES.early_years_salaried.name)
    end

    def given_i_have_created_an_early_years_undergrad_trainee
      choose_training_route_for(ReferenceData::TRAINING_ROUTES.early_years_undergrad.name)
    end

    def given_i_have_created_a_pg_teaching_apprenticeship_trainee
      choose_training_route_for(ReferenceData::TRAINING_ROUTES.pg_teaching_apprenticeship.name)
    end

    def given_i_have_created_an_opt_in_undergrad_trainee
      choose_training_route_for(ReferenceData::TRAINING_ROUTES.opt_in_undergrad.name)
    end

    def given_i_have_created_an_iqts_trainee
      choose_training_route_for(ReferenceData::TRAINING_ROUTES.iqts.name)
    end

    def given_i_have_created_a_teacher_degree_apprenticeship_trainee
      choose_training_route_for(ReferenceData::TRAINING_ROUTES.teacher_degree_apprenticeship.name)
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
