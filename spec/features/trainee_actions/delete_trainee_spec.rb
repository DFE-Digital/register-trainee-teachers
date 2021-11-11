# frozen_string_literal: true

require "rails_helper"

feature "Deleting a trainee" do
  background do
    given_i_am_authenticated
  end

  scenario "deleting a draft trainee" do
    given_a_trainee_exists
    given_i_am_on_the_review_draft_page
    and_i_click_the_delete_link
    then_i_see_the_confirm_page
    then_i_click_the_delete_button
    i_am_redirected_to_the_trainee_records_list
    and_i_see_a_flash_message
    and_the_trainee_is_no_longer_listed
  end

  describe "deleting a non-draft trainee" do
    scenario "course start date is in the future" do
      given_a_trainee_starting_a_course_in_the_future
      and_i_am_on_the_trainee_record_page
      and_i_click_the_delete_link
      and_i_confirm_delete
      and_i_see_a_success_flash_message
      and_the_trainee_is_soft_deleted
    end

    scenario "course started but trainee hasn't specified a start date" do
      given_a_trainee_with_no_start_date_for_a_course_already_started
      and_i_am_on_the_trainee_record_page
      and_i_click_the_delete_link
      and_i_confirm_delete
      and_i_see_a_success_flash_message
      and_the_trainee_is_soft_deleted
    end
  end

private

  def given_a_trainee_starting_a_course_in_the_future
    given_a_trainee_exists(:trn_received,
                           :with_publish_course_details,
                           course_start_date: 10.days.from_now)
  end

  def given_a_trainee_with_no_start_date_for_a_course_already_started
    given_a_trainee_exists(:trn_received,
                           :with_publish_course_details,
                           course_start_date: 10.days.ago,
                           commencement_date: nil)
  end

  def and_i_save_the_form
    new_trainee_page.continue_button.click
  end

  def and_i_click_the_delete_link
    if trainee.draft?
      review_draft_page.delete_this_draft_link.click
    else
      record_page.delete.click
    end
  end

  def and_i_confirm_delete
    confirm_trainee_delete_page.delete_button.click
  end

  def then_i_see_the_confirm_page
    expect(page).to have_current_path("/trainees/#{trainee.slug}/confirm-delete", ignore_query: true)
  end

  def then_i_click_the_delete_button
    confirm_draft_deletions_page.delete_this_draft.click
  end

  def i_am_redirected_to_the_trainee_records_list
    expect(trainee_index_page).to be_displayed
  end

  def and_i_see_a_flash_message
    expect(review_draft_page).to have_text("Draft deleted")
  end

  def and_i_see_a_success_flash_message
    expect(trainee_index_page).to have_text("Record deleted")
  end

  def and_the_trainee_is_no_longer_listed
    expect(review_draft_page).not_to have_text("Trainee ID: 1")
  end

  def and_the_trainee_is_soft_deleted
    expect(trainee.reload.discarded_at).to be_present
  end
end
