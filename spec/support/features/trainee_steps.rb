# frozen_string_literal: true

module Features
  module TraineeSteps
    attr_reader :trainee

    def given_a_trainee_exists(*traits, **overrides)
      @trainee ||= create(:trainee, *traits, **overrides, provider: current_user.provider)
    end

    def and_return_to_the_record_page
      record_page.load
    end

    def when_i_visit_the_record_page
      record_page.load
    end

    def then_i_am_redirected_to_the_record_page
      expect(record_page).to be_displayed(id: trainee.slug)
    end

    def and_i_confirm_my_details(checked: true, section:)
      checked_option = checked ? "check" : "uncheck"
      expect(confirm_details_page).to be_displayed(id: trainee.slug, section: section)
      confirm_details_page.confirm.public_send(checked_option)
      confirm_details_page.submit_button.click
    end

    def then_i_am_redirected_to_the_review_draft_page
      expect(review_draft_page).to be_displayed(id: trainee.slug)
    end
  end
end
