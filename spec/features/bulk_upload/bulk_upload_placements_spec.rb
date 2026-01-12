# frozen_string_literal: true

require "rails_helper"

feature "bulk update page" do
  include ActiveJob::TestHelper

  before do
    given_i_am_authenticated
    given_there_are_trainees_without_placements
    and_i_visit_the_bulk_placements_page
  end

  scenario "viewing and downloading the file" do
    then_i_see_how_many_trainees_i_can_bulk_update
    and_i_see_a_filename_of_the_file_i_need_to_download
    and_i_see_the_placement_schools_section
    when_i_click_on_the_download_link
    then_i_receive_the_file
  end

  scenario "uploading the file creates placements for trainees" do
    given_there_is_a_trainee_with_matching_trn
    and_there_are_schools_for_the_placements
    when_i_upload_the_file
    then_i_see_a_success_message
    and_the_trainee_has_two_placements_via_ui
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
    expect(page).to have_content("You have 2 trainee records who do not have at least two placements")
  end

  def and_i_see_a_filename_of_the_file_i_need_to_download
    expect(page).to have_content("#{filename}-to-add-missing-prepopulated.csv")
  end

  def and_i_see_the_placement_schools_section
    expect(page).to have_content(
      "You can add a maximum of 5 placements per trainee. Enter the placement's URN in the placement columns.",
    )
    expect(page).to have_content(
      "You can add or change trainees placement details by adding them to the end of the CSV file. Adding or changing any information in the CSV will over-write placements that are associated to a school in the Register service. If you leave a space blank in the CSV it will over-write any existing information you have entered",
    )
    expect(page).to have_content(
      "You can find the URNs using Get information about schools (opens in a new tab).",
    )
    expect(page).to have_content(
      "You cannot add information in bulk if the school or setting does not have a URN. Add those placements to the trainee record manually.",
    )
    expect(page).to have_content(
      "If you do not have the information for a placement, leave the cell empty.",
    )
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

  def given_there_is_a_trainee_with_matching_trn
    @trainee_with_placements = create(
      :trainee,
      :without_required_placements,
      trn: "1234567",
      provider: current_user.organisation,
    )
  end

  def and_there_are_schools_for_the_placements
    @school1 = create(:school, urn: "100000", name: "Test School 1")
    @school2 = create(:school, urn: "100001", name: "Test School 2")
  end

  def and_the_trainee_has_two_placements_via_ui
    perform_enqueued_jobs

    visit trainee_path(@trainee_with_placements)

    expect(page).to have_content("Test School 1")
    expect(page).to have_content("Test School 2")
  end
end
