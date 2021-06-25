# frozen_string_literal: true

module Features
  module CommonSteps
    def given_i_am_on_the_review_draft_page
      review_draft_page.load(id: trainee.slug)
    end

    def and_i_am_on_the_trainee_record_page
      record_page.load(id: trainee.slug)
    end

    def given_i_visited_the_diversities_confirm_page_page
      diversities_confirm_page.load(id: trainee.slug)
    end

    def then_i_am_redirected_to_the_diversities_confirm_page_page
      expect(diversities_confirm_page).to be_displayed(id: trainee.slug)
    end

    def and_i_confirm_my_details
      confirm_details_page.confirm.check
      confirm_details_page.continue_button.click
    end

    def and_i_continue_without_confirming_details
      confirm_details_page.continue_button.click
    end

    def and_the_draft_record_has_been_reviewed
      review_draft_page.review_this_record_link.click
    end

    def and_all_sections_are_complete
      expect(check_details_page).not_to have_text("Start section")
    end

    def when_i_submit_for_trn
      check_details_page.submit_button.click
    end

    def then_i_am_redirected_to_the_trn_success_page
      expect(trn_success_page).to be_displayed(trainee_id: trainee_from_url.slug)
    end

    def then_i_am_redirected_to_the_record_page
      expect(record_page).to be_displayed(id: trainee.slug)
    end

    def then_i_am_redirected_to_the_review_draft_page
      expect(review_draft_page).to be_displayed(id: trainee.slug)
    end

    def and_i_see_my_date(date)
      expect(page).to have_text(date_for_summary_view(date))
    end
  end
end
