# frozen_string_literal: true

module Features
  module DiversityInformationSteps
    def and_the_diversity_information_is_complete
      and_disabilities_exist_in_the_system
      review_draft_page.diversity_section.link.click
      diversity_disclosure_page.yes.choose
      diversity_disclosure_page.submit_button.click
      ethnic_group_page.asian.choose
      ethnic_group_page.submit_button.click
      ethnic_background_page.bangladeshi.choose
      ethnic_background_page.submit_button.click
      disability_disclosure_page.disabled.choose
      disability_disclosure_page.submit_button.click
      disabilities_page.disability.check(@disability.name)
      disabilities_page.submit_button.click
      and_i_confirm_my_details
      and_the_diversity_information_is_marked_completed
    end

    def and_disabilities_exist_in_the_system
      @disability = create(:disability, name: "deaf")
    end

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

    def and_the_diversity_information_is_marked_completed
      expect(review_draft_page).to have_diversity_information_completed
    end
  end
end
