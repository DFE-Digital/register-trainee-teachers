# frozen_string_literal: true

module Features
  module TraineeSteps
    attr_reader :trainee

    def given_a_trainee_exists(*traits, **overrides)
      @trainee ||= create(:trainee, *traits, **overrides, provider: current_user.provider)
    end

    def and_return_to_the_summary_page
      summary_page.load
    end

    def when_i_visit_the_summary_page
      summary_page.load
    end

    def then_i_am_redirected_to_the_summary_page
      expect(summary_page).to be_displayed(id: trainee.id)
    end

    def trainee_index_page
      @trainee_index_page ||= PageObjects::Trainees::Index.new
    end

    def summary_page
      @summary_page ||= PageObjects::Trainees::Summary.new
    end

    def confirm_details_page
      @confirm_page ||= PageObjects::Trainees::ConfirmDetails.new
    end

    def and_i_confirm_my_details(checked: true, section:)
      checked_option = checked ? "check" : "uncheck"
      expect(confirm_details_page).to be_displayed(id: trainee.id, section: section)
      confirm_details_page.confirm.public_send(checked_option)
      confirm_details_page.submit_button.click
    end
  end
end
