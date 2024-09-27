# frozen_string_literal: true

require "rails_helper"

feature "bulk add trainees" do
  before do
    given_i_am_authenticated
  end

  scenario "the bulk add trainees page is not-visible when feature flag is off", feature_bulk_add_trainees: false do
    when_i_visit_the_bulk_update_index_page
    then_i_cannot_see_the_bulk_add_trainees_link
    and_i_cannot_navigate_directly_to_the_bulk_add_trainees_page
  end

  scenario "the bulk add trainees page is visible when feature flag is on", feature_bulk_add_trainees: true do
    when_i_visit_the_bulk_update_index_page
    and_i_click_the_bulk_add_trainees_page
    then_i_see_how_instructions_on_how_to_bulk_add_trainees
    and_i_see_the_empty_csv_link

    when_i_click_the_upload_button
    then_i_see_the_summary_page
  end

private

  def when_i_visit_the_bulk_update_index_page
    visit bulk_update_path
  end

  def then_i_cannot_see_the_bulk_add_trainees_link
    expect(page).not_to have_link("Bulk add new trainees")
  end

  def and_i_cannot_navigate_directly_to_the_bulk_add_trainees_page
    visit bulk_update_trainees_add_new_trainees_path
    expect(page).to have_current_path(not_found_path)
  end

  def and_i_click_the_bulk_add_trainees_page
    click_on "Bulk add new trainees"
  end

  def then_i_see_how_instructions_on_how_to_bulk_add_trainees
    expect(page).to have_current_path(bulk_update_trainees_add_new_trainees_path)
    expect(page).to have_content("Bulk add new trainees")
  end

  def and_i_see_the_empty_csv_link
    expect(page).to have_link("Download empty CSV file to add new trainees")
  end

  def when_i_click_the_upload_button
    click_on "Upload records"
  end

  def then_i_see_the_summary_page
    expect(page).to have_current_path(bulk_update_trainees_status_path)
  end
end
