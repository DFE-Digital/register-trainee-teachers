# frozen_string_literal: true

require "rails_helper"

feature "Undo trainee withdrawal" do
  include SummaryHelper

  before do
    ActiveJob::Base.queue_adapter.enqueued_jobs.clear
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = false
    when_i_am_on_the_undo_withdrawal_page
  end

  after do
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
  end

  context "validations" do
    context "comment validation" do
      scenario "no comment provided" do
        click_button "Continue"
        expect(page).to have_content("Enter a comment")
      end
    end

    context "ticket validation" do
      scenario "invalid URL" do
        fill_in "undo-withdrawal-form-comment-field", with: "asdf"
        fill_in "undo-withdrawal-form-ticket-field", with: "asdf"
        click_button "Continue"
        expect(page).to have_content("Must be a URL")
      end
    end
  end

  context "undo trainee withdrawal flow" do
    scenario "successfully undo trainee withdrawal" do
      fill_in "undo-withdrawal-form-comment-field", with: "this is the comment"
      fill_in "undo-withdrawal-form-ticket-field", with: "https://google.com"

      click_button "Continue"

      click_button "Confirm undo withdrawal"

      expect(page).to have_current_path(trainee_path(trainee))
      record_page.timeline_tab.click

      expect(page).to have_content("this is the comment")
      expect(page).to have_content("https://google.com")
      expect(trainee.reload.state).not_to eql "withdrawn"
      expect(trainee.withdraw_reason).to be_nil
      expect(trainee.withdraw_date).to be_nil
      expect(trainee.additional_withdraw_reason).to be_nil
    end
  end

  context "cancel withdrawal flow" do
    scenario "clears the session store" do
      fill_in "undo-withdrawal-form-comment-field", with: "this is the comment"
      fill_in "undo-withdrawal-form-ticket-field", with: "https://google.com"

      click_button "Continue"
      click_button "Cancel and return to record"

      record_page.undo_withdrawal.click
      click_link "Continue"
      expect(page).not_to have_content("this is the comment")
    end
  end

  def when_i_am_on_the_undo_withdrawal_page
    given_i_am_authenticated
    current_user.update(system_admin: true)
    given_a_trainee_exists(:withdrawn)
    and_i_am_on_the_trainee_record_page
    record_page.undo_withdrawal.click
    click_link "Continue"
  end
end
