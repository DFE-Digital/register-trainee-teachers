# frozen_string_literal: true

require "rails_helper"

feature "bulk add trainees" do
  include ActiveJob::TestHelper
  include ActionView::Helpers::TextHelper
  include FileHelper

  before do
    and_there_is_a_current_academic_cycle
    and_there_is_a_previous_academic_cycle
    and_there_is_a_nationality
  end

  context "when the feature flag is off", feature_bulk_add_trainees: false do
    let(:user) { create(:user, :hei) }

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
        when_i_visit_the_bulk_update_index_page
        then_i_cannot_see_the_bulk_add_trainees_link

        when_i_visit_the_new_bulk_update_add_trainees_upload_path
        then_i_see_the_unauthorized_message
      end

      scenario "attempts to visit the upload status page" do
        when_i_visit_the_bulk_update_index_page
        then_i_cannot_see_the_bulk_view_status_link

        when_i_visit_the_bulk_update_add_trainees_uploads_page
        then_i_see_the_unauthorized_message
      end
    end

    context "when the User is not an HEI Provider" do
      before do
        given_i_am_authenticated
      end

      scenario "attempts to visit the new upload trainees page" do
        when_i_visit_the_bulk_update_index_page
        then_i_cannot_see_the_bulk_add_trainees_link

        when_i_visit_the_new_bulk_update_add_trainees_upload_path
        then_i_see_the_unauthorized_message
      end

      scenario "attempts to visit the upload status page" do
        when_i_visit_the_bulk_update_index_page
        then_i_cannot_see_the_bulk_view_status_link

        when_i_visit_the_bulk_update_add_trainees_uploads_page
        then_i_see_the_unauthorized_message
      end

      scenario "attempts to visit the upload details page" do
        when_an_upload_exist
        and_i_visit_the_bulk_update_add_trainees_upload_details_page

        then_i_see_the_unauthorized_message
      end
    end

    context "when the User is an HEI Provider" do
      let(:user) { create(:user, :hei) }

      before do
        given_i_am_authenticated(user:)

        allow(SendCsvSubmittedForProcessingEmailService).to receive(:call)
      end

      scenario "the bulk add trainees page is visible", js: true do
        when_i_visit_the_bulk_update_index_page
        and_i_click_the_bulk_add_trainees_page
        then_i_see_instructions_on_how_to_bulk_add_trainees
        and_i_see_the_empty_csv_link

        when_i_click_the_empty_csv_link
        then_i_receive_the_empty_csv_file

        when_i_visit_the_new_bulk_update_add_trainees_upload_path
        and_i_click_the_guidance_link
        then_i_see_the_bulk_add_trainees_guidance_page

        when_i_click_the_documentation_empty_csv_link
        then_i_receive_the_empty_csv_file

        when_i_visit_the_new_bulk_update_add_trainees_upload_path
        and_i_attach_an_empty_file
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

        when_i_click_the_view_status_of_new_trainee_files_link
        then_i_see_the_upload_status_row_as_pending(BulkUpdate::TraineeUpload.last)

        when_the_background_job_is_run
        and_i_refresh_the_index_page
        then_i_see_the_upload_status_row_as_validated(BulkUpdate::TraineeUpload.last)

        when_i_click_on_an_upload(upload: BulkUpdate::TraineeUpload.last)
        and_i_see_the_review_page_without_validation_errors
        and_i_dont_see_the_review_errors_link
        and_i_dont_see_the_back_to_bulk_updates_link

        when_i_click_the_cancel_bulk_updates_link
        then_the_upload_is_cancelled

        when_i_visit_the_bulk_update_add_trainees_uploads_page
        then_i_dont_see_the_cancelled_upload

        when_i_try_resubmit_the_same_upload
        then_i_see_the_unauthorized_message

        when_i_visit_the_bulk_update_index_page
        and_i_click_the_bulk_add_trainees_page
        and_i_attach_a_valid_file
        and_i_click_the_upload_button
        then_a_job_is_queued_to_process_the_upload
        then_i_see_that_the_upload_is_processing

        when_the_background_job_is_run
        and_i_refresh_the_page
        then_i_see_the_review_page_without_validation_errors

        when_an_unexpected_duplicate_error_is_setup
        and_i_click_the_submit_button
        and_a_job_is_queued_to_process_the_upload
        and_the_send_csv_processing_email_has_been_sent
        and_the_background_job_is_run
        and_i_refresh_the_summary_page
        and_i_see_the_summary_page

        when_i_click_on_resubmit_the_file_link
        and_i_see_the_number_of_trainees_that_can_be_added(number: 4)
        and_i_dont_see_any_validation_errors
        and_i_see_the_duplicate_errors(number: 1)
        and_i_see_the_review_errors_message
        and_i_see_the_review_errors_link
        and_i_dont_see_the_submit_button

        when_i_click_the_review_errors_link
        then_i_see_the_review_errors_page_with_one_error

        when_the_unexpected_duplicate_error_is_been_reverted
        and_i_return_to_the_review_errors_page
        and_i_attach_a_valid_file
        Timecop.travel 1.hour.from_now do
          and_i_click_the_upload_button
        end
        then_i_see_that_the_upload_is_processing
        then_a_job_is_queued_to_process_the_upload

        when_the_background_job_is_run
        and_i_refresh_the_page
        and_i_see_the_review_page_without_validation_errors
        and_i_dont_see_the_review_errors_link
        and_i_dont_see_the_back_to_bulk_updates_link
        and_i_click_the_submit_button

        then_a_job_is_queued_to_process_the_upload
        and_the_send_csv_processing_email_has_been_sent

        when_the_background_job_is_run
        and_i_refresh_the_summary_page

        and_i_see_the_summary_page
        and_i_dont_see_the_review_errors_message

        when_i_click_on_home_link
        then_i_see_the_root_page

        and_i_visit_the_trainees_page
        then_i_can_see_the_new_trainees

        when_i_visit_the_bulk_update_index_page
        and_i_click_on_view_status_of_uploaded_trainee_files
        then_i_see_the_bulk_update_add_trainees_uploads_index_page

        when_i_click_on_an_upload(upload: BulkUpdate::TraineeUpload.succeeded.last)
        then_i_see_the_bulk_update_add_trainees_upload_details_page

        when_i_click_on_back_link
        then_i_see_the_bulk_update_add_trainees_uploads_index_page

        when_i_try_resubmit_the_same_upload
        then_i_see_the_bulk_update_add_trainees_upload_details_page
      end

      scenario "the bulk add trainees page is visible and I upload a file with placements" do
        when_i_visit_the_bulk_update_index_page
        and_i_click_the_bulk_add_trainees_page
        and_i_attach_a_valid_file_with_placements
        and_i_click_the_upload_button
        then_a_job_is_queued_to_process_the_upload
        then_i_see_that_the_upload_is_processing

        when_the_background_job_is_run
        and_i_refresh_the_page
        then_i_see_the_review_page_without_validation_errors

        Timecop.travel 1.hour.from_now do
          and_i_click_the_submit_button
        end

        then_a_job_is_queued_to_process_the_upload

        when_the_background_job_is_run
        and_i_refresh_the_summary_page

        and_i_see_the_summary_page
        and_i_dont_see_the_review_errors_message

        when_i_click_on_home_link
        then_i_see_the_root_page

        and_i_visit_the_trainees_page
        then_i_can_see_the_new_trainees_with_placements
      end

      scenario "the bulk add trainees page is visible and I upload a file with a degree" do
        when_i_visit_the_bulk_update_index_page
        and_i_click_the_bulk_add_trainees_page
        and_i_attach_a_valid_file_with_a_degree
        and_i_click_the_upload_button
        then_a_job_is_queued_to_process_the_upload
        then_i_see_that_the_upload_is_processing

        when_the_background_job_is_run
        and_i_refresh_the_page
        then_i_see_the_review_page_without_validation_errors

        Timecop.travel 1.hour.from_now do
          and_i_click_the_submit_button
        end

        then_a_job_is_queued_to_process_the_upload

        when_the_background_job_is_run
        and_i_refresh_the_summary_page

        and_i_see_the_summary_page
        and_i_dont_see_the_review_errors_message

        when_i_click_on_home_link
        then_i_see_the_root_page

        and_i_visit_the_trainees_page
        then_i_can_see_the_new_trainees_with_a_degree
      end

      scenario "when I try to look at the status of a different providers upload" do
        when_there_is_a_bulk_update_trainee_upload

        expect {
          when_i_visit_the_bulk_update_add_trainees_status_page_for_another_provider
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      scenario "attempt to resubmit a failed upload" do
        when_a_failed_upload_without_row_errors_exist
        and_i_visit_the_bulk_update_trainee_upload_page
        then_i_do_not_see_the_submit_button
      end

      scenario "view the upload summary page with errors" do
        when_the_upload_has_failed_with_validation_errors
        and_i_dont_see_that_the_upload_is_processing
        and_i_visit_the_summary_page(upload: @failed_upload)
        then_i_see_the_review_page_without_validation_errors
        and_i_see_the_number_of_trainees_that_can_be_added(number: 3)
        and_i_see_the_validation_errors(number: 2)
        and_i_dont_see_any_duplicate_errors
        and_i_see_the_review_errors_message
        and_i_see_the_review_errors_link
        and_i_dont_see_the_submit_button

        when_i_click_the_cancel_bulk_updates_link
        then_the_upload_is_cancelled
      end

      scenario "view the upload summary page with duplicate errors" do
        when_the_upload_has_failed_with_duplicate_errors
        and_i_dont_see_that_the_upload_is_processing
        and_i_visit_the_summary_page(upload: @failed_upload)
        then_i_see_the_review_page_without_validation_errors
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
        then_i_see_the_review_page_without_validation_errors
        and_i_dont_the_number_of_trainees_that_can_be_added
        and_i_see_the_validation_errors(number: 2)
        and_i_see_the_duplicate_errors(number: 3)
        and_i_see_the_review_errors_message
        and_i_see_the_review_errors_link
        and_i_dont_see_the_submit_button
      end

      scenario "when I try to upload a file with errors then upload a corrected file", js: true do
        when_i_visit_the_bulk_update_index_page
        and_i_click_the_bulk_add_trainees_page
        then_i_see_instructions_on_how_to_bulk_add_trainees

        when_i_attach_a_file_with_invalid_rows
        and_i_click_the_upload_button
        when_the_background_job_is_run
        and_i_refresh_the_page
        then_i_see_the_review_page_without_validation_errors

        when_the_background_job_is_run
        and_i_refresh_the_page
        then_i_see_the_review_page_with_validation_errors

        when_i_click_the_review_errors_link
        then_i_see_the_review_errors_page

        when_i_click_on_back_link
        then_i_see_the_review_page_with_validation_errors

        when_i_click_the_review_errors_link
        then_i_see_the_review_errors_page

        when_i_visit_the_review_errors_page
        and_i_click_on_back_link
        then_i_see_the_review_page_with_validation_errors

        when_i_click_the_review_errors_link
        then_i_see_the_review_errors_page

        when_i_click_on_the_download_link
        then_i_receive_the_file

        when_i_return_to_the_review_errors_page
        and_i_attach_a_valid_file
        and_i_click_the_upload_button
        then_i_see_that_the_upload_is_processing
      end

      scenario "view the upload status page" do
        when_multiple_uploads_exist
        and_i_visit_the_bulk_update_index_page
        and_i_click_on_view_status_of_uploaded_trainee_files
        then_i_see_the_uploads

        when_i_click_on_back_link
        then_i_see_the_bulk_update_index_page

        when_an_upload_exists_from_the_previous_academic_cycle
        and_i_click_on_view_status_of_uploaded_trainee_files
        then_i_dont_see_the_upload

        when_i_click_on_an_upload(upload: BulkUpdate::TraineeUpload.succeeded.first)
        then_i_see_the_bulk_update_add_trainees_upload_details_page

        when_i_click_on_back_link
        then_i_see_the_bulk_update_add_trainees_uploads_index_page

        when_i_click_on_back_link
        then_i_see_the_bulk_update_index_page

        when_i_click_the_view_status_of_new_trainee_files_link(full_link: true)
        and_i_click_on_an_upload(upload: BulkUpdate::TraineeUpload.in_progress.first)
        then_i_see_the_summary_page(upload: BulkUpdate::TraineeUpload.in_progress.first)

        when_i_click_on_back_link
        then_i_see_the_bulk_update_add_trainees_uploads_index_page

        when_i_click_on_back_link
        then_i_see_the_bulk_update_index_page

        when_i_click_the_view_status_of_new_trainee_files_link(full_link: true)
        and_i_click_on_an_upload(upload: BulkUpdate::TraineeUpload.failed.first)
        then_i_see_the_review_errors_page(upload: BulkUpdate::TraineeUpload.failed.first)

        when_i_click_on_back_link
        then_i_see_the_bulk_update_add_trainees_uploads_index_page

        when_i_click_on_back_link
        then_i_see_the_bulk_update_index_page
        and_i_click_the_view_status_of_new_trainee_files_link(full_link: true)

        and_i_click_on_cancel_link
        then_i_see_the_root_page
      end

      scenario "when I try to upload a file with duplicate trainees" do
        when_there_is_already_one_trainee_in_register
        and_i_visit_the_bulk_update_index_page
        and_i_click_the_bulk_add_trainees_page
        then_i_see_instructions_on_how_to_bulk_add_trainees

        when_i_attach_a_valid_file
        and_i_click_the_upload_button
        when_the_background_job_is_run
        and_i_refresh_the_page
        then_i_see_that_there_is_one_duplicate_error

        when_i_click_the_review_errors_link
        then_i_see_the_review_errors_page_with_one_error
      end

      context "with an upload with an uploaded status" do
        let(:upload) { create(:bulk_update_trainee_upload, provider: current_user.organisation) }

        scenario "attempt import the rows of an upload" do
          when_a_request_is_made_to_the_imports_action(upload:)
          and_i_visit_the_summary_page(upload:)
          then_i_see_that_the_upload_is_processing(upload:)
        end
      end
    end

    context "when the User is not authenticated", js: true do
      scenario "view guidance docs" do
        when_i_visit_the_csv_docs_home_path
        and_i_click_the_documentation_empty_csv_link
        then_i_receive_the_empty_csv_file
      end
    end
  end

private

  def when_a_request_is_made_to_the_imports_action(upload:)
    page.driver.post(bulk_update_add_trainees_imports_path(upload))
  end

  def then_i_see_the_root_page
    expect(page).to have_content("Your trainee teachers")
  end

  def and_i_click_on_cancel_link
    click_on "Cancel reviewing uploads"
  end

  def when_an_upload_exists_from_the_previous_academic_cycle
    @previous_academic_cycle_upload ||= Timecop.travel(
      rand(AcademicCycle.previous.start_date..AcademicCycle.previous.end_date),
    ) do
      create(
        :bulk_update_trainee_upload,
        :succeeded,
        provider: current_user.organisation,
      )
    end
  end

  def then_i_dont_see_the_upload
    expect(page).not_to have_content(
      @previous_academic_cycle_upload.submitted_at.to_fs(:govuk_date_and_time),
    )
  end

  def and_there_is_a_current_academic_cycle
    create(:academic_cycle, :current)
  end

  def and_there_is_a_previous_academic_cycle
    create(:academic_cycle, :previous)
  end

  def then_i_see_the_bulk_update_add_trainees_uploads_index_page
    expect(page).to have_content("Status of new trainee files")
  end

  def when_i_click_on_an_upload(upload: BulkUpdate::TraineeUpload.last)
    if upload.failed?
      find("tr a[href^='#{bulk_update_add_trainees_review_error_path(upload)}']").click
    else
      find("tr a[href^='#{bulk_update_add_trainees_upload_path(upload)}']").click
    end
  end

  def then_i_see_the_bulk_update_add_trainees_upload_details_page
    expect(page).to have_content("Your new trainees have been registered")
    expect(page).to have_content(/Submitted by:\s*#{current_user.name}/)
    expect(page).to have_content(/Number of registered trainees:\s*5/)
    expect(page).to have_content("You can also check the status of new trainee files.")
    expect(page).to have_content("Check data submitted into Register from CSV bulk add new trainees")
    expect(page).to have_content("You can check your trainee data once it has been submitted into Register. At any time you can:")
    expect(page).to have_content(
      "view 'Choose trainee status export' from the 'Registered trainees' section, using the 'academic year' or 'start year' filter to select the current academic year",
    )
    expect(page).to have_content(
      "check your trainees directly in the service one by one",
    )
  end

  def and_i_click_on_back_link
    click_on "Back"
  end

  def when_i_click_the_view_status_of_new_trainee_files_link(full_link: false)
    link = if full_link
             "View status of previously uploaded new trainee files"
           else
             "status of new trainee files"
           end

    click_on link
  end

  def then_i_see_the_upload_status_row_as_pending(upload)
    expect(page).to have_content("#{upload.filename} Pending", normalize_ws: true)
  end

  def then_i_see_the_upload_status_row_as_validated(upload)
    expect(page).to have_content("#{upload.filename} Validated", normalize_ws: true)
  end

  def when_multiple_uploads_exist
    BulkUpdate::TraineeUpload.statuses.each_key do |status|
      Timecop.travel(rand(AcademicCycle.current.start_date..AcademicCycle.current.end_date)) do
        create(
          :bulk_update_trainee_upload,
          status,
          provider: current_user.organisation,
          submitted_by: current_user,
        )
      end
    end
  end

  def when_an_upload_exist
    create(:bulk_update_trainee_upload, provider: current_user.organisation)
  end

  def and_i_visit_the_bulk_update_trainee_uploads_page
    visit bulk_update_add_trainees_uploads_path
  end

  def and_i_click_on_view_status_of_uploaded_trainee_files
    click_on "View status of previously uploaded new trainee files"
  end

  def then_i_see_the_uploads
    expect(page).to have_content(current_user.organisation.name)

    expect(page).to have_content("Status of new trainee files")
    expect(page).to have_content("View the status of recently uploaded files containing new trainees.")
    expect(page).to have_content("This will list all successful new trainee uploads for the current academic year.")
    expect(page).to have_content("Failed uploads will be removed after 30 days.")

    expect(page).to have_content(
      "five_trainees.csv Pending",
    )
    expect(page).to have_content(
      "five_trainees.csv Validated",
    )
    expect(page).to have_content(
      "five_trainees.csv Cancelled",
    )
    expect(page).to have_content(
      "#{BulkUpdate::TraineeUpload.in_progress.take.submitted_at.to_fs(:govuk_date_and_time)} five_trainees.csv In progress",
    )
    expect(page).to have_content(
      "#{BulkUpdate::TraineeUpload.succeeded.take.submitted_at.to_fs(:govuk_date_and_time)} five_trainees.csv Succeeded",
    )
    expect(page).to have_content(
      "#{BulkUpdate::TraineeUpload.failed.take.submitted_at.to_fs(:govuk_date_and_time)} five_trainees.csv Failed",
    )
  end

  def when_there_is_already_one_trainee_in_register
    create(
      :trainee,
      :completed,
      provider: current_user.organisation,
      training_route: :provider_led_undergrad,
      first_names: "Spencer",
      last_name: "Murphy",
      email: "spencer.murphy@example.com",
      date_of_birth: "1967-12-06",
      itt_start_date: Date.new(2024, 10, 1),
    )
  end

  def when_i_try_resubmit_the_same_upload(upload: BulkUpdate::TraineeUpload.last)
    visit bulk_update_add_trainees_upload_path(upload)
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

  def and_the_bulk_upload_is_cancelled
    expect(BulkUpdate::TraineeUpload.last).to be_cancelled
  end

  def when_i_click_the_back_to_bulk_updates_page_link
    click_on "Back to bulk updates page"
  end

  def then_i_see_that_the_upload_is_processing(upload: BulkUpdate::TraineeUpload.last)
    expect(page).to have_content("File uploaded")
    expect(page).to have_content("Your file is being processed")
    expect(page).to have_content("We're currently processing #{upload.filename}.")
    expect(page).to have_content("This is taking longer than usual")
    expect(page).to have_content("You'll receive an email to tell you when this is complete.")
    expect(page).to have_content("You can also check the status of new trainee files.")
    expect(page).to have_link("Back to bulk updates page")
  end

  def and_i_dont_see_that_the_upload_is_processing(upload: BulkUpdate::TraineeUpload.last)
    expect(page).not_to have_content("File uploaded")
    expect(page).not_to have_content("Your file is being processed")
    expect(page).not_to have_content("We're currently processing #{upload.filename}.")
    expect(page).not_to have_content("This is taking longer than usual")
    expect(page).not_to have_content("You'll receive an email to tell you when this is complete.")
    expect(page).not_to have_content("You can also check the status of new trainee files.")
    expect(page).not_to have_link("Back to bulk updates page")
  end

  def and_there_is_a_nationality
    create(:nationality, :british)
  end

  def when_i_visit_the_bulk_update_index_page
    visit bulk_update_path
  end

  alias_method :and_i_visit_the_bulk_update_index_page, :when_i_visit_the_bulk_update_index_page

  def then_i_cannot_see_the_bulk_add_trainees_link
    expect(page).not_to have_link("Bulk add new trainees")
  end

  def and_i_cannot_navigate_directly_to_the_bulk_add_trainees_page
    when_i_visit_the_new_bulk_update_add_trainees_upload_path
    expect(page).to have_current_path(not_found_path)
  end

  def when_i_visit_the_new_bulk_update_add_trainees_upload_path
    visit new_bulk_update_add_trainees_upload_path
  end

  def and_i_click_the_bulk_add_trainees_page
    click_on "Bulk add new trainees"
  end

  def then_i_see_instructions_on_how_to_bulk_add_trainees
    expect(page).to have_current_path(new_bulk_update_add_trainees_upload_path)
    expect(page).to have_content("Bulk add new trainees")
  end

  def and_i_see_the_empty_csv_link
    expect(page).to have_link("Download empty CSV file to add new trainees")
  end

  def when_i_click_the_empty_csv_link
    click_on "Download empty CSV file to add new trainees"
  end

  def then_i_receive_the_empty_csv_file
    expect(page.response_headers["Content-Type"]).to eq("text/csv")
    expect(download_content).to eq(empty_file_with_headers_content)
  end

  def when_i_click_the_guidance_link
    click_on "guidance on how add trainee information to the CSV template"
  end

  def then_i_see_the_bulk_add_trainees_guidance_page
    expect(page).to have_current_path(csv_docs_home_path)
    expect(page).to have_content("How to add trainee information to the bulk add new trainee CSV template")
  end

  def when_i_visit_the_csv_docs_home_path
    visit csv_docs_home_path
  end

  def when_i_click_the_documentation_empty_csv_link
    click_on "Download empty bulk add new trainees CSV template"
  end

  def when_i_attach_an_empty_file
    and_i_attach_a_file("")
  end

  def when_i_attach_a_valid_file
    filename = "five_trainees.csv"

    and_i_attach_a_file(file_content("bulk_update/trainee_uploads/#{filename}"), filename)
  end

  def and_i_attach_a_valid_file_with_placements
    filename = "five_trainees_with_placement.csv"

    and_i_attach_a_file(file_content("bulk_update/trainee_uploads/#{filename}"), filename)
  end

  def and_i_attach_a_valid_file_with_a_degree
    filename = "five_trainees_with_degree.csv"

    and_i_attach_a_file(file_content("bulk_update/trainee_uploads/#{filename}"), filename)
  end

  def when_i_attach_a_file_with_invalid_rows
    csv = Rails.root.join("spec/fixtures/files/bulk_update/trainee_uploads/five_trainees_with_two_errors.csv").read
    and_i_attach_a_file(csv)
  end

  def and_i_attach_a_file(content, filename = "csv")
    tempfile = Tempfile.new([filename])
    tempfile.write(content)
    tempfile.rewind
    tempfile.path

    attach_file("bulk_update_bulk_add_trainees_upload_form[file]", tempfile.path)
  end

  def and_i_click_the_upload_button
    click_on "Upload records"
  end

  def then_i_see_the_upload_page_with_errors(empty:)
    expect(page).to have_current_path(bulk_update_add_trainees_uploads_path)
    expect(page).to have_content("There is a problem")
    expect(page).to have_content(empty ? "The selected file is empty" : "Select a CSV file")
  end

  def then_i_see_the_review_page_without_validation_errors
    expect(page).to have_content("You uploaded a CSV file with details of 5 trainees.")
    expect(page).to have_content("It included:")
  end

  def then_i_see_that_there_is_one_duplicate_error
    expect(page).to have_content("You uploaded a CSV file")
    expect(page).to have_content("It included:")
    and_i_see_the_duplicate_errors(number: 1)
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
    expect(page).to have_content("#{pluralize(number, 'trainee')} who will not be added, as they already exist in Register")
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

  def then_i_do_not_see_the_submit_button
    expect(page).not_to have_button("Submit")
  end

  def then_a_job_is_queued_to_process_the_upload
    expect(BulkUpdate::AddTrainees::ImportRowsJob).to have_been_enqueued.with(
      BulkUpdate::TraineeUpload.last,
    )
  end

  def and_i_see_the_summary_page(upload: BulkUpdate::TraineeUpload.last)
    expect(page).to have_current_path(
      bulk_update_add_trainees_submission_path(upload),
    )

    if upload.in_progress?
      expect(page).to have_content("Your file is being processed")
      expect(page).to have_content(
        "We're currently processing #{upload.filename}",
      )
      expect(page).to have_content("This could take several minutes if there are a large number of trainees.")
      expect(page).to have_content("You'll receive an email to tell you when this is complete.")
      expect(page).to have_content("You can also check the")
      expect(page).to have_link("status of new trainee files", href: bulk_update_add_trainees_uploads_path)
      expect(page).to have_link("Back to bulk updates page", href: bulk_update_path)

      expect(page).not_to have_content("Trainees submitted")
      expect(page).not_to have_content("You can view your trainee records to check if they are correct.")
      expect(page).not_to have_content("There are 3 ways to check trainee data in Register.")
      expect(page).not_to have_content("Choose whichever one of the following that suits you:")
      expect(page).not_to have_content("view your trainee records to check your trainees directly in the service one by on")
      expect(page).not_to have_content("use the 'Reports' section and export a CSV of your new trainees for the current academic year")
      expect(page).not_to have_content("export a CSV of your trainees in the 'Registered trainees' section, using the 'start year' filter to select the current academic year")
      expect(page).not_to have_content("View trainees' teacher reference number (TRN)")
      expect(page).not_to have_content("Once a trainee is registered, a TRN is created for each trainee record.")
      expect(page).not_to have_content("This is when the trainee becomes registered with the Department for Education (DfE).")
      expect(page).not_to have_content("You can view trainee TRNs in the Register service. This may take several minutes to appear after the bulk upload.")
      expect(page).not_to have_content("Trainees will receive their TRN by email.")

      expect(page).not_to have_content("Your submitted #{upload.filename} on #{upload.submitted_at.to_fs(:govuk_date_and_time)} has failed because:")
      expect(page).not_to have_content("you have errors in the CSV file, or")
      expect(page).not_to have_content("we could not process the CSV file")
      expect(page).not_to have_content("What you can do next")
      expect(page).not_to have_content("Check for errors in the CSV file by viewing")
      expect(page).not_to have_content("Errors are indicated in the CSV row. If you find errors then you can:")
      expect(page).not_to have_content("fix the errors in your data")
      expect(page).not_to have_content("if you cannot fix the error, you can delete the row and the trainee will not be included")
      expect(page).not_to have_content("Upload the updated CSV file.")
      expect(page).not_to have_content("If there are no errors in the CSV file, it means we could not process the CSV file.")
      expect(page).not_to have_content("You can:")
      expect(page).not_to have_content("wait for an email from the Becoming a Teacher support team asking you to re-submit the CSV file")
      expect(page).not_to have_link("re-submit the CSV file", href: bulk_update_add_trainees_upload_path(upload))
      expect(page).not_to have_content("You can check your trainee data once it has been submitted into Register. At any time you can:")
    else
      within(".govuk-panel") do
        expect(page).to have_content("Trainees submitted")
      end

      if upload.succeeded?
        expect(page).to have_content("You can view your trainee records to check if they are correct.")
        expect(page).to have_content("There are 3 ways to check trainee data in Register.")
        expect(page).to have_content("Choose whichever one of the following that suits you:")
        expect(page).to have_content("view your trainee records to check your trainees directly in the service one by on")
        expect(page).to have_content("use the 'Reports' section and export a CSV of your new trainees for the current academic year")
        expect(page).to have_content("export a CSV of your trainees in the 'Registered trainees' section, using the 'start year' filter to select the current academic year")
        expect(page).to have_content("View trainees' teacher reference number (TRN)")
        expect(page).to have_content("Once a trainee is registered, a TRN is created for each trainee record.")
        expect(page).to have_content("This is when the trainee becomes registered with the Department for Education (DfE).")
        expect(page).to have_content("You can view trainee TRNs in the Register service. This may take several minutes to appear after the bulk upload.")
        expect(page).to have_content("Trainees will receive their TRN by email.")

        expect(page).not_to have_content("Your submitted #{upload.filename} on #{upload.submitted_at.to_fs(:govuk_date_and_time)} has failed because:")
        expect(page).not_to have_content("you have errors in the CSV file, or")
        expect(page).not_to have_content("we could not process the CSV file")
        expect(page).not_to have_content("What you can do next")
        expect(page).not_to have_content("Check for errors in the CSV file by viewing")
        expect(page).not_to have_link("status of new trainee files", href: bulk_update_add_trainees_uploads_path)
        expect(page).not_to have_content("Errors are indicated in the CSV row. If you find errors then you can:")
        expect(page).not_to have_content("fix the errors in your data")
        expect(page).not_to have_content("if you cannot fix the error, you can delete the row and the trainee will not be included")
        expect(page).not_to have_content("Upload the updated CSV file.")
        expect(page).not_to have_content("If there are no errors in the CSV file, it means we could not process the CSV file.")
        expect(page).not_to have_content("You can:")
        expect(page).not_to have_content("wait for an email from the Becoming a Teacher support team asking you to re-submit the CSV file")
        expect(page).not_to have_link("re-submit the CSV file", href: bulk_update_add_trainees_upload_path(upload))
        expect(page).not_to have_content("You can check your trainee data once it has been submitted into Register. At any time you can:")
      else
        expect(page).to have_content("Your submitted #{upload.filename} on #{upload.submitted_at.to_fs(:govuk_date_and_time)} has failed because:")
        expect(page).to have_content("you have errors in the CSV file, or")
        expect(page).to have_content("we could not process the CSV file")
        expect(page).to have_content("What you can do next")
        expect(page).to have_content("Check for errors in the CSV file by viewing")
        expect(page).to have_link("status of new trainee files", href: bulk_update_add_trainees_uploads_path)
        expect(page).to have_content("Errors are indicated in the CSV row. If you find errors then you can:")
        expect(page).to have_content("fix the errors in your data")
        expect(page).to have_content("if you cannot fix the error, you can delete the row and the trainee will not be included")
        expect(page).to have_content("Upload the updated CSV file.")
        expect(page).to have_content("If there are no errors in the CSV file, it means we could not process the CSV file.")
        expect(page).to have_content("You can:")
        expect(page).to have_content("wait for an email from the Becoming a Teacher support team asking you to re-submit the CSV file")
        expect(page).to have_link("re-submit the CSV file", href: bulk_update_add_trainees_upload_path(upload))
        expect(page).to have_content("You can check your trainee data once it has been submitted into Register. At any time you can:")
        expect(page).to have_content("view your trainee records to check your trainees directly in the service one by on")
        expect(page).to have_content("use the 'Reports' section and export a CSV of your new trainees for the current academic year")
        expect(page).to have_content("export a CSV of your trainees in the 'Registered trainees' section, using the 'start year' filter to select the current academic year")
      end
    end
  end

  def when_there_is_a_bulk_update_trainee_upload
    @upload_for_different_provider = create(:bulk_update_trainee_upload)
  end

  def when_i_visit_the_bulk_update_add_trainees_status_page_for_another_provider
    visit bulk_update_add_trainees_upload_path(@upload_for_different_provider)
  end

  def and_i_refresh_the_page
    visit bulk_update_add_trainees_upload_path(BulkUpdate::TraineeUpload.last)
  end

  def and_i_refresh_the_index_page
    visit bulk_update_add_trainees_uploads_path
  end

  def and_i_refresh_the_summary_page
    visit bulk_update_add_trainees_submission_path(BulkUpdate::TraineeUpload.last)
  end

  def when_the_background_job_is_run
    perform_enqueued_jobs
  end

  def and_the_send_csv_processing_email_has_been_sent
    expect(SendCsvSubmittedForProcessingEmailService).to have_received(:call)
      .with(
        upload: BulkUpdate::TraineeUpload.last,
      )
  end

  def and_i_visit_the_trainees_page
    visit trainees_path
  end

  def then_i_can_see_the_new_trainees
    expect(page).to have_content("Spencer Murphy")
    expect(page).to have_content("Adrianne Koelpin")
    expect(page).to have_content("Sacha Bechtelar")
    expect(page).to have_content("Rico Corkery")
    expect(page).to have_content("Chantelle Raynor")
  end

  def then_i_can_see_the_new_trainees_with_placements
    expect(page).to have_content("Preston Rath")
    expect(page).to have_content("Breanne Langosh")
    expect(page).to have_content("Kirby Gerlach")
    expect(page).to have_content("Emilio Rippin")
    expect(page).to have_content("Lavonda Bins")

    click_on "Preston Rath"

    expect(page).to have_content("Placement 1")
    expect(page).to have_content("URN 609384")
    expect(page).not_to have_content("First placement is missing")
    expect(page).to have_content("Second placement is missing")
  end

  def then_i_can_see_the_new_trainees_with_a_degree
    expect(page).to have_content("Charissa Gibson")
    expect(page).to have_content("Kraig Howe")
    expect(page).to have_content("Katharyn Roberts")
    expect(page).to have_content("Maurice Bashirian")
    expect(page).to have_content("Bethanie Schumm")

    click_on "Charissa Gibson"

    expect(page).to have_content("Bachelor of Humanities")
    expect(page).to have_content("general or integrated engineering")
    expect(page).to have_content("Point Blank Music School")
    expect(page).to have_content("Third-class honours")
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

  def then_the_upload_is_cancelled
    expect(page).to have_current_path(bulk_update_path)
    expect(page).to have_content("Bulk updates to records have been cancelled")
  end

  def then_i_dont_see_the_cancelled_upload(upload: BulkUpdate::TraineeUpload.cancelled.last)
    expect(page).not_to have_content(upload.filename)
  end

  def and_i_visit_the_summary_page(upload:)
    visit bulk_update_add_trainees_upload_path(upload)
  end

  def then_i_see_the_review_page_with_validation_errors
    expect(page).to have_content("2 trainees with errors in their details")
  end

  def when_i_click_the_review_errors_link
    click_on "Review errors"
  end

  def then_i_see_the_review_errors_page(upload: BulkUpdate::TraineeUpload.last)
    expect(page).to have_current_path(bulk_update_add_trainees_review_error_path(upload))
    expect(page).to have_content("Review errors for #{pluralize(upload.total_rows_with_errors, 'trainee')} in the CSV that you uploaded")
  end

  def then_i_see_the_review_errors_page_with_one_error
    expect(page).to have_current_path(bulk_update_add_trainees_review_error_path(id: BulkUpdate::TraineeUpload.last.id))
    expect(page).to have_content("Review errors for 1 trainee in the CSV that you uploaded")
  end

  def when_i_click_on_the_download_link
    click_on "Download your CSV file with errors indicated"
  end

  def then_i_receive_the_file
    expect(page.response_headers["Content-Type"]).to eq("text/csv")
    expect(page.response_headers["Content-Disposition"]).to include("attachment; filename=\"trainee-upload-errors-#{BulkUpdate::TraineeUpload.last.id}.csv\"")

    expect(download_content).to eq(file_with_two_errors_content)
  end

  def when_i_return_to_the_review_errors_page
    visit bulk_update_add_trainees_review_error_path(BulkUpdate::TraineeUpload.last)
  end

  def then_i_see_the_bulk_update_index_page
    expect(page).to have_current_path(bulk_update_path)
  end

  def then_i_see_the_bulk_add_trainees_uploads_index_page
    expect(page).to have_current_path(bulk_update_add_trainees_uploads_path)
  end

  def then_i_cannot_see_the_bulk_view_status_link
    expect(page).not_to have_link("View status of previously uploaded new trainee files")
  end

  def when_i_visit_the_bulk_update_add_trainees_uploads_page
    visit bulk_update_add_trainees_uploads_path
  end

  def and_i_visit_the_bulk_update_add_trainees_upload_details_page(upload: BulkUpdate::TraineeUpload.last)
    visit bulk_update_add_trainees_upload_path(upload)
  end

  def when_i_visit_the_review_errors_page(upload: BulkUpdate::TraineeUpload.last)
    visit bulk_update_add_trainees_review_error_path(upload)
  end

  def when_an_unexpected_duplicate_error_is_setup
    file = Rails.root.join("spec/fixtures/files/bulk_update/trainee_uploads/five_trainees.csv")
    row  = CSV.read(file, headers: true)[-1]

    BulkUpdate::AddTrainees::ImportRow.call(
      row: row,
      current_provider: BulkUpdate::TraineeUpload.last.provider,
    )
  end

  def when_the_unexpected_duplicate_error_is_been_reverted
    Trainee.last.tap do |trainee|
      trainee.hesa_trainee_detail.destroy!
      trainee.destroy!
    end
  end

  def when_i_click_on_resubmit_the_file_link
    click_on "re-submit the CSV file"
  end

  def when_a_failed_upload_without_row_errors_exist
    create(
      :bulk_update_trainee_upload,
      :failed_without_errors,
      provider: current_user.organisation,
      submitted_by: current_user,
    )
  end

  def when_i_click_on_home_link
    find(".govuk-back-link", text: "Home").click
  end

  def file_with_two_errors_content
    file_content("bulk_update/trainee_uploads/failed_with_two_errors.csv")
  end

  def empty_file_with_headers_content
    file_content("bulk_update/trainee_uploads/empty_file_with_headers.csv")
  end

  alias_method :and_i_attach_a_valid_file, :when_i_attach_a_valid_file
  alias_method :and_i_click_the_submit_button, :when_i_click_the_submit_button
  alias_method :when_i_click_the_upload_button, :and_i_click_the_upload_button
  alias_method :and_i_visit_the_bulk_update_index_page, :when_i_visit_the_bulk_update_index_page
  alias_method :when_i_click_on_back_link, :and_i_click_on_back_link
  alias_method :and_i_click_the_view_status_of_new_trainee_files_link, :when_i_click_the_view_status_of_new_trainee_files_link
  alias_method :and_i_see_the_review_page_without_validation_errors, :then_i_see_the_review_page_without_validation_errors
  alias_method :when_i_visit_the_bulk_update_index_page, :and_i_visit_the_bulk_update_index_page
  alias_method :and_i_click_on_an_upload, :when_i_click_on_an_upload
  alias_method :then_i_see_the_summary_page, :and_i_see_the_summary_page
  alias_method :and_a_job_is_queued_to_process_the_upload, :then_a_job_is_queued_to_process_the_upload
  alias_method :and_the_background_job_is_run, :when_the_background_job_is_run
  alias_method :and_i_return_to_the_review_errors_page, :when_i_return_to_the_review_errors_page
  alias_method :and_i_visit_the_bulk_update_trainee_upload_page, :when_i_try_resubmit_the_same_upload
  alias_method :and_i_click_the_documentation_empty_csv_link, :when_i_click_the_documentation_empty_csv_link
  alias_method :and_i_click_the_guidance_link, :when_i_click_the_guidance_link
  alias_method :and_i_attach_an_empty_file, :when_i_attach_an_empty_file
  alias_method :when_i_visit_the_bulk_update_trainee_uploads_page, :and_i_visit_the_bulk_update_trainee_uploads_page
end
