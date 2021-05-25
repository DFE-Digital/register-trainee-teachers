# frozen_string_literal: true

module Features
  module PersonalDetailsSteps
    def and_the_personal_details_is_complete
      and_nationalities_exist_in_the_system
      review_draft_page.refresh
      review_draft_page.personal_details.link.click
      and_i_fill_in_personal_details_form
      and_i_submit_the_personal_details_form
      and_i_confirm_my_details
      and_the_personal_details_is_marked_completed
    end

    def and_i_submit_the_personal_details_form
      personal_details_page.continue_button.click
    end

    def and_i_fill_in_personal_details_form(other_nationality: false)
      personal_details_page.first_names.set("Tim")
      personal_details_page.last_name.set("Smith")
      personal_details_page.set_date_fields("dob", "01/01/1986")
      personal_details_page.gender.choose("Male")

      if other_nationality
        personal_details_page.nationality.check("Other")
        personal_details_page.other_nationality.select(@french.name.titleize)
      else
        personal_details_page.nationality.check(@british.name.titleize)
      end
    end

    def and_nationalities_exist_in_the_system
      @british ||= create(:nationality, name: "british")
      @french ||= create(:nationality, name: "french")
    end

    def and_the_personal_details_is_marked_completed
      expect(review_draft_page).to have_personal_details_completed
    end
  end
end
