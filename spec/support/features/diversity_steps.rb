# frozen_string_literal: true

module Features
  module DiversitySteps
    def given_valid_diversity_information
      @trainee.diversity_disclosure = Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed]
      @trainee.ethnic_group = Diversities::ETHNIC_GROUP_ENUMS[:asian]
      @trainee.ethnic_background = "some background"
      @trainee.disability_disclosure = Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled]
      @trainee.disabilities = [create(:disability, name: "deaf")]
      @trainee.progress.diversity = true
      @trainee.save!
    end

    def and_i_choose(option)
      ethnic_group_page.find(
        "#diversities-ethnic-group-form-ethnic-group-#{option.dasherize}-field",
      ).choose
    end

    def and_i_choose_a_background(background)
      ethnic_background_page.public_send(background).choose
    end
  end
end
