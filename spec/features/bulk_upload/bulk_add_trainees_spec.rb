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

    when_i_attach_an_empty_file
    and_i_click_the_upload_button
    then_i_see_the_upload_page_with_errors

    when_i_visit_the_bulk_update_index_page
    and_i_click_the_bulk_add_trainees_page
    and_i_attach_a_valid_file
    and_i_click_the_upload_button
    then_i_see_the_summary_page_with_no_errors
  end

  scenario "when I try to look at the status of a different providers upload", feature_bulk_add_trainees: true do
    when_there_is_a_bulk_update_trainee_upload
    when_i_visit_the_bulk_update_status_page_for_another_provider
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

  def when_i_attach_an_empty_file
    and_i_attach_a_file("")
  end

  def and_i_attach_a_valid_file
    and_i_attach_a_file("trainee_id,first_name,last_name,email\n1,Bob,Roberts,bob@example.com\n1,Alice,Roberts,alice@example.com")
  end

  def and_i_attach_a_file(content)
    tempfile = Tempfile.new("csv")
    tempfile.write(content)
    tempfile.rewind
    tempfile.path

    attach_file("bulk_update_bulk_add_trainees_form[file]", tempfile.path)
  end

  def and_i_click_the_upload_button
    click_on "Upload records"
  end

  def then_i_see_the_upload_page_with_errors
    expect(page).to have_current_path(bulk_update_trainees_add_new_trainees_path)
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("The selected file is empty")
  end

  def then_i_see_the_summary_page_with_no_errors
    expect(page).to have_current_path(
      bulk_update_trainees_status_path(id: BulkUpdate::TraineeUpload.last.id),
    )
    expect(page).to have_content("You uploaded a CSV file with details of 2 trainees.")
  end

  def when_there_is_a_bulk_update_trainee_upload
    @upload_for_different_provider = create(:bulk_update_trainee_upload)
  end

  def when_i_visit_the_bulk_update_status_page_for_another_provider
    visit bulk_update_trainees_status_path(id: @upload_for_different_provider.id)
  end

  def then_i_see_a_not_found_page
    expect(page).to have_current_path(not_found_path)
  end
end
