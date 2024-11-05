# frozen_string_literal: true

require "rails_helper"

feature "bulk add trainees" do
  include ActiveJob::TestHelper

  before do
    and_there_is_a_nationality
  end

  context "when the feature flag is off", feature_bulk_add_trainees: false do
    before do
      given_i_am_authenticated
    end

    scenario "the bulk add trainees page is not-visible when feature flag is off" do
      when_i_visit_the_bulk_update_index_page
      then_i_cannot_see_the_bulk_add_trainees_link
      and_i_cannot_navigate_directly_to_the_bulk_add_trainees_page
    end
  end

  context "when the feature flag is on", feature_bulk_add_trainees: true do
    context "when the User is not a Provider" do
      let(:user) { create(:user, :with_lead_partner_organisation) }

      before do
        given_i_am_authenticated(user:)
      end

      scenario "attempts to visit the new upload trainees page" do
        when_i_visit_the_new_bulk_update_trainees_upload_path
        then_i_see_the_unauthorized_message
      end
    end

    context "when the User is a Provider" do
      before do
        given_i_am_authenticated
      end

      scenario "the bulk add trainees page is visible" do
        when_i_visit_the_bulk_update_index_page
        and_i_click_the_bulk_add_trainees_page
        then_i_see_how_instructions_on_how_to_bulk_add_trainees
        and_i_see_the_empty_csv_link

        when_i_attach_an_empty_file
        and_i_click_the_upload_button
        then_i_see_the_upload_page_with_errors(empty: true)

        when_i_click_the_upload_button
        then_i_see_the_upload_page_with_errors(empty: false)

        when_i_visit_the_bulk_update_index_page
        and_i_click_the_bulk_add_trainees_page
        and_i_attach_a_valid_file
        and_i_click_the_upload_button
        then_i_see_that_the_upload_is_processing
        and_i_dont_see_the_cancel_bulk_updates_link

        when_i_click_the_back_to_bulk_updates_page_link
        and_i_click_the_bulk_add_trainees_page
        and_i_attach_a_valid_file

        and_i_click_the_upload_button
        then_i_see_that_the_upload_is_processing

        when_the_background_job_is_run
        and_i_refresh_the_page
        then_i_see_the_review_page
        and_i_dont_see_the_review_errors_link
        and_i_dont_see_the_back_to_bulk_updates_link

        when_i_click_the_cancel_bulk_updates_link
        and_i_click_the_bulk_add_trainees_page
        and_i_attach_a_valid_file
        and_i_click_the_upload_button
        then_a_job_is_queued_to_process_the_upload
        then_i_see_that_the_upload_is_processing

        when_the_background_job_is_run
        and_i_refresh_the_page
        then_i_see_the_review_page

        when_i_click_the_submit_button
        then_a_job_is_queued_to_process_the_upload
        and_i_see_the_summary_page
        and_i_dont_see_the_review_errors_message

        and_i_visit_the_trainees_page
        then_i_can_see_the_new_trainees

        when_i_try_resubmit_the_same_upload
        and_i_click_the_submit_button
        then_i_see_the_unauthorized_message
      end

      scenario "when I try to look at the status of a different providers upload" do
        when_there_is_a_bulk_update_trainee_upload

        expect {
          when_i_visit_the_bulk_update_status_page_for_another_provider
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      scenario "view the upload summary page with errors" do
        when_the_upload_has_failed_with_validation_errors
        and_i_dont_see_that_the_upload_is_processing
        and_i_visit_the_summary_page(upload: @failed_upload)
        then_i_see_the_review_page
        and_i_see_the_number_of_trainees_that_can_be_added(number: 3)
        and_i_see_the_validation_errors(number: 2)
        and_i_dont_see_any_duplicate_errors
        and_i_see_the_review_errors_message
        and_i_see_the_review_errors_link
        and_i_dont_see_the_submit_button
      end

      scenario "view the upload summary page with duplicate errors" do
        when_the_upload_has_failed_with_duplicate_errors
        and_i_dont_see_that_the_upload_is_processing
        and_i_visit_the_summary_page(upload: @failed_upload)
        then_i_see_the_review_page
        and_i_see_the_number_of_trainees_that_can_be_added(number: 3)
        and_i_dont_see_any_validation_errors
        and_i_see_the_duplicate_errors(number: 2)
        and_i_see_the_review_errors_message
        and_i_see_the_review_errors_link
        and_i_dont_see_the_submit_button
      end

      scenario "view the upload summary page with validation and duplicate errors" do
        when_the_upload_has_failed_with_validation_and_duplicate_errors
        and_i_dont_see_that_the_upload_is_processing
        and_i_visit_the_summary_page(upload: @failed_upload)
        then_i_see_the_review_page
        and_i_dont_the_number_of_trainees_that_can_be_added
        and_i_see_the_validation_errors(number: 2)
        and_i_see_the_duplicate_errors(number: 3)
        and_i_see_the_review_errors_message
        and_i_see_the_review_errors_link
        and_i_dont_see_the_submit_button
      end
    end
  end

private

  def when_i_try_resubmit_the_same_upload
    visit bulk_update_trainees_upload_path(BulkUpdate::TraineeUpload.last)
  end

  def then_i_see_the_unauthorized_message
    expect(page).to have_content("You do not have permission to perform this action")
  end

  def and_i_dont_see_the_back_to_bulk_updates_link
    expect(page).not_to have_link("Back to bulk updates page")
  end

  def and_i_dont_see_the_cancel_bulk_updates_link
    expect(page).not_to have_link("Cancel bulk updates to records")
  end

  def when_i_click_the_cancel_bulk_updates_link
    click_on "Cancel bulk updates to records"
  end

  def when_i_click_the_back_to_bulk_updates_page_link
    click_on "Back to bulk updates page"
  end

  def then_i_see_that_the_upload_is_processing
    expect(page).to have_content("File uploaded")
    expect(page).to have_content("Your file is being processed")
    expect(page).to have_content("We're currently processing #{BulkUpdate::TraineeUpload.last.filename}.")
    expect(page).to have_content("This is taking longer than usual")
    expect(page).to have_content("You'll receive and email to tell you when this is complete.")
    expect(page).to have_content("You can also check the status of new trainee files.")
    expect(page).to have_link("Back to bulk updates page")
  end

  def and_i_dont_see_that_the_upload_is_processing
    expect(page).not_to have_content("File uploaded")
    expect(page).not_to have_content("Your file is being processed")
    expect(page).not_to have_content("We're currently processing #{BulkUpdate::TraineeUpload.last.filename}.")
    expect(page).not_to have_content("This is taking longer than usual")
    expect(page).not_to have_content("You'll receive and email to tell you when this is complete.")
    expect(page).not_to have_content("You can also check the status of new trainee files.")
    expect(page).not_to have_link("Back to bulk updates page")
  end

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
    when_i_visit_the_new_bulk_update_trainees_upload_path
    expect(page).to have_current_path(not_found_path)
  end

  def when_i_visit_the_new_bulk_update_trainees_upload_path
    visit new_bulk_update_trainees_upload_path
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

  def when_i_attach_a_valid_file
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

  def then_i_see_the_upload_page_with_errors(empty:)
    expect(page).to have_current_path(bulk_update_trainees_uploads_path)
    expect(page).to have_content("There is a problem")
    expect(page).to have_content(empty ? "The selected file is empty" : "Select a CSV file")
  end

  def then_i_see_the_review_page
    expect(page).to have_content("You uploaded a CSV file with details of 5 trainees.")
    expect(page).to have_content("It included:")
  end

  def and_i_see_the_number_of_trainees_that_can_be_added(number:)
    expect(page).to have_content("#{number} trainees who can be added")
  end

  def and_i_dont_the_number_of_trainees_that_can_be_added
    expect(page).not_to have_content("trainees who can be added")
  end

  def and_i_see_the_validation_errors(number:)
    expect(page).to have_content("#{number} trainees with errors in their details")
  end

  def and_i_see_the_duplicate_errors(number:)
    expect(page).to have_content("#{number} trainees who will not be added, as they already exist in Register")
  end

  def and_i_see_the_review_errors_message
    expect(page).to have_content("You need to review the errors before you can add new trainees")
  end

  def and_i_dont_see_the_review_errors_message
    expect(page).not_to have_content("You need to review the errors before you can add new trainees")
  end

  def and_i_dont_see_any_validation_errors
    expect(page).not_to have_content("0 trainees with errors in their details")
  end

  def and_i_dont_see_any_duplicate_errors
    expect(page).not_to have_content("0 trainees who will not be added, as they already exist in Register")
  end

  def and_i_dont_see_the_submit_button
    expect(page).not_to have_button("Submit")
  end

  def and_i_see_the_review_errors_link
    expect(page).to have_link("Review errors")
  end

  def and_i_dont_see_the_review_errors_link
    expect(page).not_to have_link("Review errors")
  end

  def when_i_click_the_submit_button
    click_on "Submit"
  end

  def then_a_job_is_queued_to_process_the_upload
    expect(BulkUpdate::AddTrainees::ImportRowsJob).to have_been_enqueued.with(
      id: BulkUpdate::TraineeUpload.last.id,
    )
  end

  def and_i_see_the_summary_page
    expect(page).to have_current_path(
      bulk_update_trainees_submission_path(BulkUpdate::TraineeUpload.last),
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
    visit bulk_update_trainees_upload_path(@upload_for_different_provider)
  end

  def and_i_refresh_the_page
    visit bulk_update_trainees_upload_path(id: BulkUpdate::TraineeUpload.last.id)
  end

  def when_the_background_job_is_run
    perform_enqueued_jobs
  end

  def and_i_visit_the_trainees_page
    visit trainees_path
  end

  def then_i_can_see_the_new_trainees
    expect(page).to have_content("Jonas Padberg")
  end

  def when_the_upload_has_failed_with_validation_errors
    @failed_upload = create(
      :bulk_update_trainee_upload,
      :failed_with_validation_errors,
      provider: current_user.organisation,
    )
  end

  def when_the_upload_has_failed_with_duplicate_errors
    @failed_upload = create(
      :bulk_update_trainee_upload,
      :failed_with_duplicate_errors,
      provider: current_user.organisation,
    )
  end

  def when_the_upload_has_failed_with_validation_and_duplicate_errors
    @failed_upload = create(
      :bulk_update_trainee_upload,
      :failed,
      provider: current_user.organisation,
    )
  end

  def and_i_visit_the_summary_page(upload:)
    visit bulk_update_trainees_upload_path(upload)
  end

  alias_method :and_i_attach_a_valid_file, :when_i_attach_a_valid_file
  alias_method :and_i_click_the_submit_button, :when_i_click_the_submit_button
  alias_method :when_i_click_the_upload_button, :and_i_click_the_upload_button
end
