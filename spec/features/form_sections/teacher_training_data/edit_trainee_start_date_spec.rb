# frozen_string_literal: true

require "rails_helper"

feature "edit Trainee start date" do
  include SummaryHelper

  let(:new_start_date) { Date.tomorrow }

  background do
    given_i_am_authenticated
  end

  scenario "updates the start date" do
    given_a_trainee_exists(:submitted_for_trn)
    when_i_visit_the_edit_trainee_start_date_page
    when_i_change_the_start_date
    when_i_click_continue
    then_i_am_taken_to_the_confirmation_page
    when_i_confirm
    then_i_am_redirected_to_the_record_page
    then_the_trainee_start_date_is_updated
  end

  scenario "start date is not set" do
    given_a_trainee_exists(:submitted_for_trn, commencement_date: nil)
    when_i_visit_the_edit_trainee_start_date_page
    then_i_am_redirected_to_the_edit_trainee_start_status_page
  end

  def when_i_visit_the_edit_trainee_start_date_page
    trainee_start_date_edit_page.load(trainee_id: trainee.slug)
  end

  def when_i_change_the_start_date
    trainee_start_date_edit_page.set_date_fields(:commencement_date, new_start_date.strftime("%d/%m/%Y"))
  end

  def when_i_click_continue
    trainee_id_edit_page.continue.click
  end

  def then_i_am_taken_to_the_confirmation_page
    expect(page).to have_current_path("/trainees/#{trainee.slug}/trainee-start-date/confirm", ignore_query: true)
  end

  def then_i_am_redirected_to_the_edit_trainee_start_status_page
    expect(page).to have_current_path("/trainees/#{trainee.slug}/trainee-start-status/edit")
  end

  def when_i_confirm
    confirm_trainee_id_page.confirm.click
  end

  def then_the_trainee_start_date_is_updated
    expect(record_page.record_detail.start_date_row).to have_text(date_for_summary_view(new_start_date))
  end
end
