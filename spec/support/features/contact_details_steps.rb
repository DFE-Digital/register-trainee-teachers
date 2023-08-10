# frozen_string_literal: true

module Features
  module ContactDetailsSteps
    def and_the_contact_details_is_complete
      review_draft_page.contact_details.link.click
      and_i_fill_in_the_contact_details_form
      and_i_submit_the_contact_details_form
      and_i_confirm_my_details
      and_the_contact_details_is_marked_completed
    end

    def and_i_fill_in_the_contact_details_form
      contact_details_page.email.set(Faker::Internet.email)
    end

    def and_i_submit_the_contact_details_form
      contact_details_page.submit_button.click
    end

    def and_the_contact_details_is_marked_completed
      expect(review_draft_page).to have_contact_details_completed
    end
  end
end
