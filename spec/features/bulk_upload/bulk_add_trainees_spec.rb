# frozen_string_literal: true

require "rails_helper"

feature "bulk add trainees" do
  context "when authenticated as a provider user" do
    let(:hei_provider) { create(:provider, :hei) }
    let(:user) { create(:user, providers: [hei_provider]) }

    before do
      allow(BulkUpdate::AddTrainees::ImportRowsJob).to receive(:perform_later)
      allow(SendCsvSubmittedForProcessingEmailService).to receive(:call)
      given_i_am_authenticated(user:)
      and_there_is_a_nationality
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
      then_i_see_the_review_page_with_no_errors

      when_the_upload_validation_background_job_is_run
      and_i_refresh_the_page
      then_i_see_the_review_page_with_no_errors

      when_i_click_the_submit_button
      then_a_job_is_queued_to_process_the_upload
      and_the_send_csv_processing_email_has_been_sent
      and_i_see_the_summary_page

      when_the_submit_background_job_is_run
      and_i_visit_the_trainees_page
      then_i_can_see_the_new_trainees
    end

    scenario "when I try to look at the status of a different providers upload", feature_bulk_add_trainees: true do
      when_there_is_a_bulk_update_trainee_upload
      when_i_visit_the_bulk_update_status_page_for_another_provider
    end
  end

  context "when authenticated but not as a provider user" do
    before do
      given_i_am_authenticated_as_system_admin
    end

    scenario "the bulk add trainees page is visible when feature flag is on", feature_bulk_add_trainees: true do
      when_i_visit_the_bulk_update_add_trainees_page
      then_i_am_redirected_to_the_root_path
    end
  end

  def when_i_visit_the_bulk_update_add_trainees_page
    visit new_bulk_update_trainees_upload_path
  end

  def then_i_am_redirected_to_the_root_path
    expect(page).to have_current_path(root_path)
  end

private

  def and_there_is_a_nationality
    create(:nationality, :british)
  end

  def when_i_visit_the_bulk_update_index_page
    visit bulk_update_path
  end

  def then_i_cannot_see_the_bulk_add_trainees_link
    expect(page).not_to have_link("Bulk add new trainees")
  end

  def and_i_cannot_navigate_directly_to_the_bulk_add_trainees_page
    visit new_bulk_update_trainees_upload_path
    expect(page).to have_current_path(not_found_path)
  end

  def and_i_click_the_bulk_add_trainees_page
    click_on "Bulk add new trainees"
  end

  def then_i_see_how_instructions_on_how_to_bulk_add_trainees
    expect(page).to have_current_path(new_bulk_update_trainees_upload_path)
    expect(page).to have_content("Bulk add new trainees")
  end

  def and_i_see_the_empty_csv_link
    expect(page).to have_link("Download empty CSV file to add new trainees")
  end

  def when_i_attach_an_empty_file
    and_i_attach_a_file("")
  end

  def and_i_attach_a_valid_file
    csv = Rails.root.join("spec/fixtures/files/bulk_update/trainee_uploads/five_trainees.csv").read
    and_i_attach_a_file(csv)
  end

  def and_i_attach_a_file(content)
    tempfile = Tempfile.new("csv")
    tempfile.write(content)
    tempfile.rewind
    tempfile.path

    attach_file("bulk_update_bulk_add_trainees_upload_form[file]", tempfile.path)
  end

  def and_i_click_the_upload_button
    click_on "Upload records"
  end

  def then_i_see_the_upload_page_with_errors
    expect(page).to have_current_path(bulk_update_trainees_uploads_path)
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("The selected file is empty")
  end

  def then_i_see_the_review_page_with_no_errors
    expect(page).to have_current_path(
      bulk_update_trainees_upload_path(id: BulkUpdate::TraineeUpload.last.id),
    )
    expect(page).to have_content("You uploaded a CSV file with details of 5 trainees.")
  end

  def when_i_click_the_submit_button
    click_on "Submit"
  end

  def then_a_job_is_queued_to_process_the_upload
    expect(BulkUpdate::AddTrainees::ImportRowsJob).to have_received(:perform_later).with(BulkUpdate::TraineeUpload.last).at_least(:once)
  end

  def and_i_see_the_summary_page
    expect(page).to have_current_path(
      bulk_update_trainees_submission_path(id: BulkUpdate::TraineeUpload.last.id),
    )
    within(".govuk-panel") do
      expect(page).to have_content("Trainees submitted")
    end
    expect(page).to have_content("There are 3 ways to check trainee data in Register.")
  end

  def when_there_is_a_bulk_update_trainee_upload
    @upload_for_different_provider = create(:bulk_update_trainee_upload)
  end

  def when_i_visit_the_bulk_update_status_page_for_another_provider
    visit bulk_update_trainees_upload_path(id: @upload_for_different_provider.id)
  end

  def then_i_see_a_not_found_page
    expect(page).to have_current_path(not_found_path)
  end

  def when_the_upload_validation_background_job_is_run
    Sidekiq::Testing.inline! do
      BulkUpdate::AddTrainees::ImportRowsJob.perform_now(BulkUpdate::TraineeUpload.last)
    end
  end

  def and_i_refresh_the_page
    visit bulk_update_trainees_upload_path(id: BulkUpdate::TraineeUpload.last.id)
  end

  def when_the_submit_background_job_is_run
    Sidekiq::Testing.inline! do
      BulkUpdate::AddTrainees::ImportRowsJob.perform_now(BulkUpdate::TraineeUpload.last)
    end
  end

  def and_the_send_csv_processing_email_has_been_sent
    expect(SendCsvSubmittedForProcessingEmailService).to have_received(:call).with(user: current_user, upload: BulkUpdate::TraineeUpload.last).at_least(:once)
  end

  def and_i_visit_the_trainees_page
    visit trainees_path
  end

  def then_i_can_see_the_new_trainees
    expect(page).to have_content("Jonas Padberg")
  end
end
