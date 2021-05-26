# frozen_string_literal: true

module Features
  module TrainingDetailsSteps
    def and_the_trainee_start_date_and_id_is_complete
      review_draft_page.training_details.link.click
      training_details_page
      and_i_fill_in_the_training_details_form
      and_i_confirm_my_details
      expect(review_draft_page).to have_training_details_completed
    end

    def and_i_fill_in_the_training_details_form
      training_details_page.trainee_id.set("123")
      training_details_page.set_date_fields(:commencement_date, Date.tomorrow.strftime("%d/%m/%Y"))
      training_details_page.submit_button.click
    end
  end
end
