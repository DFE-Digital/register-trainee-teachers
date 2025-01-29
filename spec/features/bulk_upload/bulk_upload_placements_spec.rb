# frozen_string_literal: true

require "rails_helper"

feature "bulk update page" do
  before do
    given_i_am_authenticated
    given_there_are_trainees_without_placements
    and_i_visit_the_bulk_placements_page
  end

  scenario "viewing and downloading the file" do
    then_i_see_how_many_trainees_i_can_bulk_update
    and_i_see_a_filename_of_the_file_i_need_to_download
    when_i_click_on_the_download_link
    then_i_receive_the_file
  end

  scenario "uploading the file" do
    when_i_upload_the_file
    then_i_see_a_success_message
  end

  scenario "uploading an un-readable file" do
    when_i_upload_the_unreadable_file
    then_i_see_an_error_message
  end

  scenario "uploading file with missing trn" do
    when_i_upload_the_file_with_missing_trn
    then_i_see_an_error_message
  end

private

  def then_i_see_how_many_trainees_i_can_bulk_update
    expect(page).to have_content("2 that can be bulk updated")
  end

  def and_i_see_a_filename_of_the_file_i_need_to_download
    expect(page).to have_content("#{filename}-to-add-missing-prepopulated.csv")
  end

  def given_there_are_trainees_without_placements
    create_list(:trainee, 2, :without_required_placements, provider: current_user.organisation)
  end

  def and_i_visit_the_bulk_placements_page
    visit new_bulk_update_placements_path
  end

  def filename
    current_user.organisation.name.parameterize
  end

  def when_i_click_on_the_download_link
    click_on "Download trainees with missing details"
  end

  def then_i_receive_the_file
    expect(page.response_headers["Content-Type"]).to eq("text/csv")
    expect(page.response_headers["Content-Disposition"]).to include("attachment; filename=\"#{filename}-to-add-missing-prepopulated.csv\"")
  end

  def when_i_upload_the_file
    attach_file("bulk_update_placements_form[file]", file_fixture("bulk_update/placements/complete.csv"))
    click_on "Upload records"
  end

  def when_i_upload_the_unreadable_file
    attach_file("bulk_update_placements_form[file]", file_fixture("bulk_update/placements/un-readable.csv"))
    click_on "Upload records"
  end

  def when_i_upload_the_file_with_missing_trn
    attach_file("bulk_update_placements_form[file]", file_fixture("bulk_update/placements/missing_trn.csv"))
    click_on "Upload records"
  end

  def then_i_see_a_success_message
    expect(page).to have_content("Placement data submitted")
  end

  def then_i_see_an_error_message
    expect(page).to have_content("There was an issue uploading your CSV file")
  end
end
