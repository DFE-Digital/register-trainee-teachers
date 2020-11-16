module Features
  module TraineeSteps
    attr_reader :trainee

    def given_a_trainee_exists(attributes = {})
      @trainee ||= create(:trainee, **attributes, provider: current_user.provider)
    end

    def and_return_to_the_summary_page
      summary_page.load
    end

    def then_i_am_redirected_to_the_summary_page
      expect(summary_page).to be_displayed(id: trainee.id)
    end

    def then_the_personal_details_section_should_be_completed
      expect(summary_page.personal_details.status.text).to eq(Progress::STATUSES[:completed])
    end

    def then_the_personal_details_section_should_be_in_progress
      expect(summary_page.personal_details.status.text).to eq(Progress::STATUSES[:in_progress])
    end

    def summary_page
      @summary_page ||= PageObjects::Trainees::Summary.new
    end

    def confirm_details_page
      @confirm_page ||= PageObjects::Trainees::ConfirmDetails.new
    end
  end
end
