# frozen_string_literal: true

module Features
  module TrainingPartnerAndEmployingSchoolSteps
    def and_the_training_partner_and_employing_schools_section_is_complete
      given_training_partner_and_employing_school_exist_in_the_system
      review_draft_page.training_partner_and_employing_schools_section.link.click
      and_i_choose_the_not_applicable_training_partner_option(false)
      and_i_continue
      and_i_fill_in_my_training_partner
      and_i_continue
      training_partners_search_page.choose_training_partner(id: @training_partner.id)
      and_i_continue
      and_i_choose_the_not_applicable_employing_school_option(false)
      and_i_continue
      and_i_fill_in_my_employing_school
      and_i_continue
      employing_schools_search_page.choose_school(id: @employing_school.id)
      and_i_continue
      and_i_confirm_my_details
      and_the_training_partner_and_employing_schools_section_is_marked_completed
    end

    def and_the_training_partner_section_is_complete
      given_a_training_partner_exists_in_the_system
      review_draft_page.training_partner_and_employing_schools_section.link.click
      and_i_choose_the_not_applicable_training_partner_option(false)
      and_i_continue
      and_i_fill_in_my_training_partner
      and_i_continue
      training_partners_search_page.choose_training_partner(id: @training_partner.id)
      and_i_continue
      and_i_confirm_my_details
      and_the_training_partner_and_employing_schools_section_is_marked_completed
    end

  private

    def given_training_partner_and_employing_school_exist_in_the_system
      given_a_training_partner_exists_in_the_system
      @employing_school = create(:school)
    end

    def given_a_training_partner_exists_in_the_system
      @training_partner = create(:training_partner, :school)
    end

    def and_i_fill_in_my_training_partner
      edit_training_partner_page.training_partner_no_js.fill_in with: @training_partner.name.split.first
    end

    def and_i_fill_in_my_employing_school
      edit_employing_school_page.employing_school_no_js.fill_in with: @employing_school.name.split.first
    end

    def and_i_continue
      click_on("Continue")
    end

    def and_the_training_partner_and_employing_schools_section_is_marked_completed
      expect(review_draft_page).to have_training_partner_and_employing_school_information_completed
    end

    def and_i_choose_the_not_applicable_training_partner_option(value)
      edit_trainee_training_partner_details_page.select_radio_button(value)
    end

    def and_i_choose_the_not_applicable_employing_school_option(value)
      edit_trainee_employing_school_details_page.select_radio_button(value)
    end
  end
end
