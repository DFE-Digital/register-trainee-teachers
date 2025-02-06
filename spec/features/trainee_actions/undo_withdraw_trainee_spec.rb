# frozen_string_literal: true

require "rails_helper"

feature "Undo trainee withdrawal" do
  include_context "perform enqueued jobs"

  include SummaryHelper

  before do
    ActiveJob::Base.queue_adapter.enqueued_jobs.clear
    when_i_am_on_the_undo_withdrawal_page
  end

  let(:withdrawal) { trainee.trainee_withdrawals.last }

  context "validations" do
    context "comment validation" do
      scenario "no comment provided" do
        and_i_continue
        then_i_expect_the_page_to_show_comment_error
      end
    end
  end

  context "undo trainee withdrawal flow" do
    scenario "successfully undo trainee withdrawal" do
      and_i_fill_in_the_form(comment: "this is the comment", ticket: "https://google.com")
      and_i_continue
      and_i_confirm

      record_page.timeline_tab.click

      then_i_expect_the_timeline_to_show_the_comment_and_ticket
      then_i_expect_the_trainee_to_have_been_updated
    end
  end

  context "cancel withdrawal flow" do
    scenario "clears the session store" do
      and_i_fill_in_the_form(comment: "this is the comment", ticket: "https://google.com")

      and_i_continue
      and_i_cancel

      then_i_expect_the_session_to_have_been_cleared
    end
  end

  def and_i_fill_in_the_form(comment: nil, ticket: nil)
    edit_undo_withdrawal_page.comment.set(comment)
    edit_undo_withdrawal_page.ticket.set(ticket)
  end

  def and_i_continue
    edit_undo_withdrawal_page.continue.click
  end

  def and_i_confirm
    undo_withdrawal_confirmation_page.confirm.click
  end

  def and_i_cancel
    undo_withdrawal_confirmation_page.cancel.click
  end

  def when_i_am_on_the_undo_withdrawal_page
    given_i_am_authenticated
    current_user.update(system_admin: true)
    given_a_trainee_exists(:withdrawn_for_specific_reason)
    and_i_am_on_the_trainee_record_page
    record_page.undo_withdrawal.click
    click_on "Continue"
  end

  def then_i_expect_the_page_to_show_url_error
    expect(page).to have_content("Must be a URL")
  end

  def then_i_expect_the_page_to_show_comment_error
    expect(page).to have_content("Enter a comment")
  end

  def then_i_expect_the_timeline_to_show_the_comment_and_ticket
    expect(page).to have_content("this is the comment")
  end

  def then_i_expect_the_trainee_to_have_been_updated
    expect(trainee.reload.state).not_to eql "withdrawn"
    expect(withdrawal.withdrawal_reasons).not_to be_empty
    expect(trainee.withdraw_date).to be_nil
    expect(trainee.withdraw_reasons_details).to be_nil
    expect(trainee.withdraw_reasons_dfe_details).to be_nil
    expect(withdrawal.discarded_at).not_to be_nil
    expect(trainee.audits.last.comment).to have_text("https://google.com")
  end

  def then_i_expect_the_session_to_have_been_cleared
    record_page.undo_withdrawal.click
    show_undo_withdrawal_page.continue.click
    expect(page).not_to have_content("this is the comment")
  end
end
