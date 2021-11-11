# frozen_string_literal: true

require "rails_helper"

feature "edit Trainee start status" do
  include SummaryHelper

  let(:new_start_date) { Date.tomorrow }

  context "for a non-draft trainee" do
    background do
      given_i_am_authenticated
    end

    scenario "when the trainee has started on time" do
      given_a_trainee_exists(:submitted_for_trn, :course_start_date_in_the_past)
      when_i_visit_the_edit_trainee_start_status_page
      when_i_choose_the_trainee_has_started_on_time
      when_i_change_the_start_date
      when_i_click_continue
      then_i_am_taken_to_the_confirmation_page
      when_i_confirm
      then_i_am_redirected_to_the_record_page
      then_the_trainee_start_date_is_updated_with_the_course_start_date
    end

    scenario "when the trainee has started later" do
      given_a_trainee_exists(:submitted_for_trn, :course_start_date_in_the_past)
      when_i_visit_the_edit_trainee_start_status_page
      when_i_choose_the_trainee_has_started_later
      when_i_change_the_start_date
      when_i_click_continue
      then_i_am_taken_to_the_confirmation_page
      when_i_confirm
      then_i_am_redirected_to_the_record_page
      then_the_trainee_start_date_is_updated
    end

    scenario "when the trainee has not yet started" do
      given_a_trainee_exists(:submitted_for_trn, :course_start_date_in_the_future)
      when_i_visit_the_edit_trainee_start_status_page
      when_i_choose_the_trainee_has_not_yet_started
      when_i_click_continue
      then_i_am_taken_to_the_confirmation_page
      when_i_confirm
      then_i_am_redirected_to_the_record_page
      then_the_trainee_commencement_status_is_updated_to_not_yet_started
    end
  end

  context "for a draft trainee" do
    background do
      given_i_am_authenticated
      given_a_trainee_exists(:draft, :completed)
      when_i_visit_the_edit_trainee_start_status_page
    end

    scenario "they are submitted for TRN" do
      when_i_choose_the_trainee_has_not_yet_started
      when_i_click_continue
      then_i_am_redirected_to_the_trn_success_page
    end
  end

  def when_i_visit_the_edit_trainee_start_status_page
    trainee_start_status_edit_page.load(trainee_id: trainee.slug)
  end

  def when_i_choose_the_trainee_has_started_on_time
    trainee_start_status_edit_page.commencement_status_started_on_time.choose
  end

  def when_i_choose_the_trainee_has_started_later
    trainee_start_status_edit_page.commencement_status_started_later.choose
  end

  def when_i_choose_the_trainee_has_not_yet_started
    trainee_start_status_edit_page.commencement_status_not_yet_started.choose
  end

  def when_i_change_the_start_date
    trainee_start_status_edit_page.set_date_fields(:commencement_date, new_start_date.strftime("%d/%m/%Y"))
  end

  def when_i_click_continue
    training_details_page.continue.click
  end

  def then_i_am_taken_to_the_confirmation_page
    expect(page).to have_current_path("/trainees/#{trainee.slug}/trainee-start-status/confirm")
  end

  def when_i_confirm
    confirm_training_details_page.confirm.click
  end

  def then_the_trainee_start_date_is_updated
    expect(record_page.record_detail.start_date_row).to have_text(date_for_summary_view(new_start_date))
  end

  def then_the_trainee_start_date_is_updated_with_the_course_start_date
    expect(record_page.record_detail.start_date_row).to have_text(date_for_summary_view(trainee.course_start_date))
  end

  def then_the_trainee_commencement_status_is_updated_to_not_yet_started
    expect(record_page.record_detail.start_date_row).to have_text(I18n.t("record_details.view.itt_has_not_started"))
  end

  def then_i_am_redirected_to_the_trn_success_page
    expect(trn_success_page).to be_displayed
  end
end
