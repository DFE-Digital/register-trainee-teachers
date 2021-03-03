# frozen_string_literal: true

require "rails_helper"

feature "Create a draft trainee" do
  background do
    given_i_am_authenticated
    given_a_trainee_exists
    given_i_visited_the_review_draft_page
  end

  scenario "deleting a draft trainee" do
    and_i_click_the_delete_link
    then_i_see_the_confirm_page
    then_i_click_the_delete_button
    i_am_redirected_to_the_trainee_records_list
    and_i_see_a_flash_message
    and_the_trainee_is_no_longer_listed
  end

private

  def and_i_save_the_form
    new_trainee_page.continue_button.click
  end

  def and_i_click_the_delete_link
    review_draft_page.delete_this_draft_link.click
  end

  def then_i_see_the_confirm_page
    expect(page.current_path).to eq("/trainees/#{trainee.slug}/confirm-delete")
  end

  def then_i_click_the_delete_button
    confirm_draft_deletions_page.delete_this_draft.click
  end

  def i_am_redirected_to_the_trainee_records_list
    expect(page.current_path).to eq("/trainees")
  end

  def and_i_see_a_flash_message
    expect(page).to have_text("Draft deleted")
  end

  def and_the_trainee_is_no_longer_listed
    expect(page).to_not have_text("Trainee ID: 1")
  end
end
