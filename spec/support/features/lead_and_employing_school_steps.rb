# frozen_string_literal: true

module Features
  module LeadAndEmployingSchoolSteps
    def and_the_lead_and_employing_schools_section_is_complete
      given_lead_and_employing_schools_exist_in_the_system
      review_draft_page.lead_and_employing_schools_section.link.click
      and_i_fill_in_my_lead_school
      and_i_continue
      lead_schools_search_page.choose_school(id: @lead_school.id)
      and_i_continue
      and_i_fill_in_my_employing_school
      and_i_continue
      employing_schools_search_page.choose_school(id: @employing_school.id)
      and_i_continue
      and_i_confirm_my_details
      and_the_lead_and_employing_schools_section_is_marked_completed
    end

    def and_the_lead_school_section_is_complete
      given_a_lead_school_exists_in_the_system
      review_draft_page.lead_and_employing_schools_section.link.click
      and_i_fill_in_my_lead_school
      and_i_continue
      lead_schools_search_page.choose_school(id: @lead_school.id)
      and_i_continue
      and_i_confirm_my_details
      and_the_lead_and_employing_schools_section_is_marked_completed
    end

  private

    def given_lead_and_employing_schools_exist_in_the_system
      given_a_lead_school_exists_in_the_system
      @employing_school = create(:school)
    end

    def given_a_lead_school_exists_in_the_system
      @lead_school = create(:school, :lead)
    end

    def and_i_fill_in_my_lead_school
      edit_lead_school_page.no_js_lead_school.fill_in with: @lead_school.name.split(" ").first
    end

    def and_i_fill_in_my_employing_school
      edit_employing_school_page.no_js_employing_school.fill_in with: @employing_school.name.split(" ").first
    end

    def and_i_continue
      find('button.govuk-button[type="submit"]').click
    end

    def and_the_lead_and_employing_schools_section_is_marked_completed
      expect(review_draft_page).to have_lead_and_employing_school_information_completed
    end
  end
end
