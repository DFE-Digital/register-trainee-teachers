# frozen_string_literal: true

require "rails_helper"

feature "bulk add trainees" do
  include ActiveJob::TestHelper
  include ActionView::Helpers::TextHelper
  include FileHelper

  before do
    and_there_is_a_current_academic_cycle
    and_there_is_a_previous_academic_cycle
    and_we_are_at_least_one_month_into_the_academic_cycle
    and_there_is_a_nationality
    and_there_are_disabilities
    and_there_are_funding_rules
  end

  def and_we_are_at_least_one_month_into_the_academic_cycle
    Timecop.travel([AcademicCycle.current.start_date + 1.month, Time.zone.today].max)
  end

  def and_there_are_funding_rules
    undergrad_funding_rule = create(
      :funding_method,
      training_route: :provider_led_undergrad,
      funding_type: :scholarship,
      academic_cycle: @academic_cycle,
    )
    school_direct_funding_rule = create(
      :funding_method,
      training_route: :school_direct_salaried,
      funding_type: :scholarship,
      academic_cycle: @academic_cycle,
    )
    allocation_subject = create(
      :allocation_subject,
    )
    create(
      :subject_specialism,
      allocation_subject: allocation_subject,
      name: "primary teaching",
    )
    create(
      :funding_method_subject,
      funding_method: undergrad_funding_rule,
      allocation_subject: allocation_subject,
    )
    create(
      :funding_method_subject,
      funding_method: school_direct_funding_rule,
      allocation_subject: allocation_subject,
    )
  end

  context "when the feature flag is off", feature_bulk_add_trainees: false do
    context "when the User is signed in as an HEI Provider" do
      let(:user) { create(:user, :hei) }

      before do
        given_i_am_authenticated
      end

      scenario "the bulk add trainees page is not-visible" do
        when_i_visit_the_bulk_update_index_page
        then_i_cannot_see_the_bulk_add_trainees_link
        and_i_cannot_navigate_directly_to_the_bulk_add_trainees_page
      end
    end

    context "when the User is not signed in", js: true do
      scenario "they can download the empty CSV template from the documentation page" do
        when_i_visit_the_csv_docs_home_path
        when_i_click_the_documentation_empty_csv_link
        then_i_receive_the_empty_csv_file
      end
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
        allow(SendCsvSubmittedForProcessingFirstStageEmailService).to receive(:call)
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

        when_i_visit_the_new_bulk_update_add_trainees_upload_path
        and_i_attach_an_empty_file
        and_i_click_the_upload_button
        then_i_see_the_upload_page_with_errors(empty: true)

        when_i_click_the_upload_button
        then_i_see_the_upload_page_with_errors

        when_i_visit_the_bulk_update_index_page
        and_i_click_the_bulk_add_trainees_page
        and_i_attach_a_valid_file
        and_i_click_the_upload_button
        then_i_see_the_new_bulk_update_import_page

        when_i_click_on_back_link
        then_i_see_instructions_on_how_to_bulk_add_trainees

        when_i_attach_a_valid_file
        and_i_click_the_upload_button
        then_i_see_the_new_bulk_update_import_page

        and_i_click_the_cancel_process_link
        then_the_upload_is_cancelled

        when_i_click_the_bulk_add_trainees_page
        and_i_see_instructions_on_how_to_bulk_add_trainees
        and_i_attach_a_valid_file
        and_i_click_the_upload_button
        and_i_see_the_new_bulk_update_import_page
        and_i_click_on_continue_button
        and_the_send_csv_processing_first_stage_email_has_been_sent
        then_i_see_that_the_upload_is_processing
        and_i_dont_see_the_cancel_bulk_updates_link

        when_i_click_the_back_to_bulk_updates_page_link
        and_i_click_the_bulk_add_trainees_page
        and_i_attach_a_valid_file
        and_i_click_the_upload_button
        and_i_see_the_new_bulk_update_import_page
        and_i_click_on_continue_button
        then_i_see_that_the_upload_is_processing

        when_i_click_on_back_link
        then_i_see_instructions_on_how_to_bulk_add_trainees

        when_i_attach_a_valid_file
        and_i_click_the_upload_button
        and_i_see_the_new_bulk_update_import_page
        and_i_click_on_continue_button
        then_i_see_that_the_upload_is_processing

        when_i_click_the_view_status_of_new_trainee_files_link
        then_i_see_the_upload_status_row_as_pending(BulkUpdate::TraineeUpload.last)

        when_the_background_job_is_run
        and_i_refresh_the_index_page
        then_i_see_the_upload_status_row_as_validated(BulkUpdate::TraineeUpload.last)

        when_i_click_on_an_upload(upload: BulkUpdate::TraineeUpload.last)
        and_i_see_file_validation_passed
        and_i_dont_see_the_review_errors_link
        and_i_dont_see_the_back_to_bulk_updates_link

        when_i_click_the_cancel_submission_link
        then_the_upload_is_cancelled

        when_i_visit_the_bulk_update_add_trainees_uploads_page
        then_i_dont_see_the_cancelled_upload

        when_i_try_resubmit_the_same_upload
        then_i_see_the_unauthorized_message

        when_i_visit_the_bulk_update_index_page
        and_i_click_the_bulk_add_trainees_page
        and_i_attach_a_valid_file
        and_i_click_the_upload_button
        and_i_see_the_new_bulk_update_import_page
        and_i_click_on_continue_button
        and_the_send_csv_processing_first_stage_email_has_been_sent
        then_a_job_is_queued_to_process_the_upload
        then_i_see_that_the_upload_is_processing

        when_the_background_job_is_run
        and_i_refresh_the_page
        then_i_see_file_validation_passed

        when_an_unexpected_duplicate_error_is_setup
        and_i_click_the_submit_button
        and_a_job_is_queued_to_process_the_upload
        and_the_send_csv_processing_email_has_been_sent
        and_the_background_job_is_run
        and_i_refresh_the_summary_page
        then_i_see_the_review_errors_page
        and_i_dont_see_the_submit_button

        when_i_click_the_upload_button
        then_i_see_the_review_errors_page
        and_i_see_there_is_a_problem_errors

        when_the_unexpected_duplicate_error_is_been_reverted
        and_i_attach_a_valid_file
        Timecop.travel 1.hour.from_now do
          and_i_click_the_upload_button
        end
        and_i_click_on_continue_button
        and_the_send_csv_processing_first_stage_email_has_been_sent
        then_i_see_that_the_upload_is_processing
        then_a_job_is_queued_to_process_the_upload

        when_the_background_job_is_run
        and_i_refresh_the_page
        and_i_see_file_validation_passed
        and_i_dont_see_the_review_errors_link
        and_i_dont_see_the_back_to_bulk_updates_link
        and_i_click_the_submit_button

        then_a_job_is_queued_to_process_the_upload
        and_the_send_csv_processing_email_has_been_sent

        when_the_background_job_is_run
        and_i_refresh_the_summary_page
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
        and_i_click_on_continue_button
        and_the_send_csv_processing_first_stage_email_has_been_sent
        then_a_job_is_queued_to_process_the_upload
        then_i_see_that_the_upload_is_processing

        when_the_background_job_is_run
        and_i_refresh_the_page
        and_i_see_file_validation_passed

        Timecop.travel 1.hour.from_now do
          and_i_click_the_submit_button
        end

        then_a_job_is_queued_to_process_the_upload

        when_the_background_job_is_run
        and_i_refresh_the_summary_page

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
        and_i_click_on_continue_button
        and_the_send_csv_processing_first_stage_email_has_been_sent
        then_a_job_is_queued_to_process_the_upload
        then_i_see_that_the_upload_is_processing

        when_the_background_job_is_run
        and_i_refresh_the_page
        and_i_see_file_validation_passed

        Timecop.travel 1.hour.from_now do
          and_i_click_the_submit_button
        end

        then_a_job_is_queued_to_process_the_upload

        when_the_background_job_is_run
        and_i_refresh_the_summary_page
        and_i_dont_see_the_review_errors_message

        when_i_click_on_home_link
        then_i_see_the_root_page

        and_i_visit_the_trainees_page
        then_i_can_see_the_new_trainees_with_a_degree
      end

      scenario "the bulk add trainees page is visible and I upload a file with a disability" do
        when_i_visit_the_bulk_update_index_page
        and_i_click_the_bulk_add_trainees_page
        and_i_attach_a_valid_file_with_a_disability
        and_i_click_the_upload_button
        and_i_click_on_continue_button
        and_the_send_csv_processing_first_stage_email_has_been_sent
        then_a_job_is_queued_to_process_the_upload
        then_i_see_that_the_upload_is_processing

        when_the_background_job_is_run
        and_i_refresh_the_page
        and_i_see_file_validation_passed

        Timecop.travel 1.hour.from_now do
          and_i_click_the_submit_button
        end

        then_a_job_is_queued_to_process_the_upload

        when_the_background_job_is_run
        and_i_refresh_the_summary_page
        and_i_dont_see_the_review_errors_message

        when_i_click_on_home_link
        then_i_see_the_root_page

        and_i_visit_the_trainees_page
        then_i_can_see_the_new_trainees_with_a_disability
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
        then_i_see_the_review_errors_page
        and_i_dont_see_the_submit_button

        when_i_click_on_back_link
        then_i_see_instructions_on_how_to_bulk_add_trainees

        when_i_visit_the_summary_page(upload: @failed_upload)
        and_i_click_the_cancel_bulk_updates_link
        then_the_upload_is_cancelled
      end

      scenario "view the upload summary page with duplicate errors" do
        when_the_upload_has_failed_with_duplicate_errors
        and_i_dont_see_that_the_upload_is_processing
        and_i_visit_the_summary_page(upload: @failed_upload)
        then_i_see_the_review_errors_page
        and_i_dont_see_the_submit_button
      end

      scenario "view the upload summary page with validation and duplicate errors" do
        when_the_upload_has_failed_with_validation_and_duplicate_errors
        and_i_dont_see_that_the_upload_is_processing
        and_i_visit_the_summary_page(upload: @failed_upload)
        then_i_see_the_review_errors_page(upload: @failed_upload)
        and_i_dont_see_the_submit_button
      end

      scenario "when I try to upload a file with errors then upload a corrected file", js: true do
        when_i_visit_the_bulk_update_index_page
        and_i_click_the_bulk_add_trainees_page
        then_i_see_instructions_on_how_to_bulk_add_trainees

        when_i_attach_a_file_with_invalid_rows
        and_i_click_the_upload_button
        and_i_click_on_continue_button
        and_the_send_csv_processing_first_stage_email_has_been_sent
        when_the_background_job_is_run
        and_i_refresh_the_page
        then_i_see_the_review_errors_page

        when_the_background_job_is_run
        and_i_refresh_the_page
        then_i_see_the_review_errors_page

        when_i_click_on_the_download_link
        then_i_receive_the_file

        when_i_return_to_the_review_errors_page
        and_i_attach_a_valid_file
        and_i_click_the_upload_button
        and_i_click_on_continue_button
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
        and_i_click_on_continue_button
        and_the_send_csv_processing_first_stage_email_has_been_sent
        when_the_background_job_is_run
        and_i_refresh_the_page
        then_i_see_the_review_errors_page
      end

      scenario "when the uploaded file has mixed encoding" do
        when_i_visit_the_bulk_update_index_page
        and_i_click_the_bulk_add_trainees_page
        and_i_see_instructions_on_how_to_bulk_add_trainees
        and_i_attach_a_file_with_a_mixed_encoding_in_the_headers
        and_i_click_the_upload_button

        then_i_see_the_upload_page_with_errors(headers_encoding: true)

        when_i_attach_a_file_with_a_mixed_encoding_in_the_rows
        and_i_click_the_upload_button
        then_i_see_the_new_bulk_update_import_page

        and_i_click_on_continue_button
        then_a_job_is_queued_to_process_the_upload
        then_i_see_that_the_upload_is_processing

        when_the_background_job_is_run
        and_i_refresh_the_page
        and_i_see_file_validation_passed

        Timecop.travel 1.hour.from_now do
          and_i_click_the_submit_button
        end

        then_a_job_is_queued_to_process_the_upload

        when_the_background_job_is_run
        and_i_refresh_the_summary_page
        and_i_dont_see_the_review_errors_message

        when_i_click_on_home_link
        then_i_see_the_root_page

        and_i_visit_the_trainees_page
        then_i_can_see_the_new_trainees
      end

      scenario "when I try to upload a file that throws an exception in the API layer" do
        when_there_is_already_one_trainee_in_register
        and_i_visit_the_bulk_update_index_page
        and_i_click_the_bulk_add_trainees_page

        when_i_attach_a_file_with_an_unparseable_date
        and_i_click_the_upload_button
        and_i_click_on_continue_button
        and_the_send_csv_processing_first_stage_email_has_been_sent
        when_the_background_job_is_run
        and_i_refresh_the_page
        then_i_see_the_review_errors_page
      end

      scenario "when I view a list of previous uploads" do
        when_there_are_multiple_uploads
        and_i_visit_the_bulk_update_index_page
        and_i_click_on_view_status_of_uploaded_trainee_files
        then_i_see_the_uploads_in_descending_historical_order
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
    @academic_cycle = AcademicCycle.for_year(2024) || create(:academic_cycle, cycle_year: 2024)
  end

  def and_there_is_a_previous_academic_cycle
    AcademicCycle.previous || create(:academic_cycle, :previous)
  end

  def then_i_see_the_bulk_update_add_trainees_uploads_index_page
    expect(page).to have_content("Status of new trainee files")
  end

  def when_i_click_on_an_upload(upload: BulkUpdate::TraineeUpload.last)
    find("tr a[href^='#{bulk_update_add_trainees_upload_path(upload)}']").click
  end

  def then_i_see_the_bulk_update_add_trainees_upload_details_page
    expect(page).to have_content("Your new trainees have been registered")
    expect(page).to have_content(/Submitted by\s*#{current_user.name}/)
    expect(page).to have_content(/Number of registered trainees\s*5/)
    expect(page).to have_content("You can also check the status of new trainee files.")
    expect(page).to have_content("Check data submitted into Register from CSV bulk add new trainees")
    expect(page).to have_content("You can check your trainee data in Register. At any time you can:")
    expect(page).to have_content(
      "view ‘Choose trainee status export’ from the ‘Registered trainees’ section, using the ‘academic year’ or ‘start year’ filter to select the current academic year",
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
    expect(page).to have_content("#{upload.filename} In progress", normalize_ws: true)
  end

  def then_i_see_the_upload_status_row_as_validated(upload)
    expect(page).to have_content("#{upload.filename} Ready to submit", normalize_ws: true)
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
    expect(page).to have_content("Failed uploads will be removed after 30 days.")

    expect(page).not_to have_content(
      "five_trainees.csv Uploaded",
    )
    expect(page).to have_content(
      "five_trainees.csv In progress",
    )
    expect(page).to have_content(
      "five_trainees.csv Ready to submit",
    )
    expect(page).not_to have_content(
      "five_trainees.csv Cancelled",
    )
    expect(page).to have_content(
      "#{BulkUpdate::TraineeUpload.in_progress.take.submitted_at.to_fs(:govuk_date_and_time)} five_trainees.csv In progress",
    )
    expect(page).to have_content(
      "#{BulkUpdate::TraineeUpload.succeeded.take.submitted_at.to_fs(:govuk_date_and_time)} five_trainees.csv Trainees registered",
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

  def when_i_click_the_cancel_submission_link
    click_on "Cancel trainee submission to Register"
  end

  def and_the_bulk_upload_is_cancelled
    expect(BulkUpdate::TraineeUpload.last).to be_cancelled
  end

  def when_i_click_the_back_to_bulk_updates_page_link
    click_on "Back to bulk updates page"
  end

  def then_i_see_that_the_upload_is_processing
    expect(page).to have_content("Your CSV is being checked")
    expect(page).to have_content("This may take several minutes")
    expect(page).to have_content("You will receive an email telling you if errors have been found, or if you can complete the register process.")
    expect(page).to have_content("You can also check the status of new trainee files.")
    expect(page).not_to have_content("File uploaded")
    expect(page).to have_link("Back to bulk updates page")
  end

  def and_i_dont_see_that_the_upload_is_processing
    expect(page).not_to have_content("File uploaded")
    expect(page).not_to have_content("Your CSV is being checked")
    expect(page).not_to have_content("This may take several minutes")
    expect(page).not_to have_content("You will receive an email telling you if errors have been found, or if you can complete the register process.")
    expect(page).not_to have_content("You can also check the status of new trainee files.")
    expect(page).not_to have_link("Back to bulk updates page")
  end

  def and_there_is_a_nationality
    create(:nationality, :british)
  end

  def and_there_are_disabilities
    %i[
      deaf
      blind
      development_condition
      learning_difficulty
      long_standing_illness
      mental_health_condition
      physical_disability_or_mobility_issue
      social_or_communication_impairment
      other
    ].each { |name| create(:disability, name) }
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
    expect(page).not_to have_content("There is a problem")
  end

  def and_i_see_the_empty_csv_link
    expect(page).to have_link("This is the template CSV file to add new trainees.")
  end

  def when_i_click_the_empty_csv_link
    click_on "This is the template CSV file to add new trainees."
  end

  def then_i_receive_the_empty_csv_file
    expect(page.response_headers["content-type"]).to eq("text/csv")
    expect(download_filename).to eq("v2025_0_bulk_create_trainee.csv")
    expect(download_content).to eq(empty_file_with_headers_content)
  end

  def when_i_click_the_guidance_link
    @guidance_window = window_opened_by do
      click_on "guidance on how add trainee information to the CSV template"
    end
  end

  def then_i_see_the_bulk_add_trainees_guidance_page
    within_window(@guidance_window) do
      expect(page).to have_current_path("/csv-docs/")
      expect(page).to have_content("How to add trainee information to the bulk add new trainee CSV template")

      when_i_click_the_documentation_empty_csv_link
      then_i_receive_the_empty_csv_file
    end
    @guidance_window.close
    switch_to_window(windows.first)
  end

  def when_i_visit_the_csv_docs_home_path
    visit "/csv-docs/"
  end

  def when_i_click_the_documentation_empty_csv_link
    click_on "Download empty bulk add new trainees CSV template"
  end

  def when_i_attach_an_empty_file
    and_i_attach_a_file("")
  end

  def and_i_attach_a_file_with_a_mixed_encoding_in_the_headers
    filename = "mixed_headers_encoding.csv"

    and_i_attach_a_file(file_content("bulk_update/trainee_uploads/#{filename}"), filename)
  end

  def when_i_attach_a_file_with_a_mixed_encoding_in_the_rows
    filename = "mixed_rows_encoding.csv"

    and_i_attach_a_file(file_content("bulk_update/trainee_uploads/#{filename}"), filename)
  end

  def when_i_attach_a_valid_file
    filename = "five_trainees.csv"

    and_i_attach_a_file(file_content("bulk_update/trainee_uploads/#{filename}"), filename)
  end

  def when_i_attach_a_file_with_an_unparseable_date
    filename = "five_trainees_with_unparseable_date.csv"

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

  def and_i_attach_a_valid_file_with_a_disability
    filename = "five_trainees_with_disability.csv"

    and_i_attach_a_file(file_content("bulk_update/trainee_uploads/#{filename}"), filename)
  end

  def when_i_attach_a_file_with_invalid_rows
    csv = Rails.root.join("spec/fixtures/files/bulk_update/trainee_uploads/five_trainees_with_failed.csv").read
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
    click_on "Upload CSV"
  end

  def then_i_see_the_upload_page_with_errors(empty: false, headers_encoding: false)
    expect(page).to have_current_path(bulk_update_add_trainees_uploads_path)
    and_i_see_there_is_a_problem_errors(empty:, headers_encoding:)
  end

  def and_i_see_there_is_a_problem_errors(empty: false, headers_encoding: false)
    content = if empty
                "The selected file is empty"
              elsif headers_encoding
                "Your file’s column names need to match the CSV template. " \
                  "Your file is missing the following columns: 'Application ID'. " \
                  "Your file has the following extra columns: 'Ápplication ID'"
              else
                "Select a CSV file"
              end

    expect(page).to have_content("There is a problem")
    expect(page).to have_content(content)
  end

  def and_i_see_file_validation_passed
    expect(page).to have_content("Your file has been approved")
  end

  def then_i_see_the_validated_upload_page
    expect(page).to have_content("You uploaded a CSV file with details of 5 trainees.")
    expect(page).to have_content("It included:")
  end

  def and_i_dont_see_the_review_errors_message
    expect(page).not_to have_content("Review errors for")
    expect(page).not_to have_content("You cannot add new trainees if there’s an error in their row in the CSV file")
  end

  def and_i_dont_see_the_submit_button
    expect(page).not_to have_button("Submit")
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
    visit bulk_update_add_trainees_upload_path(BulkUpdate::TraineeUpload.last)
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

  def and_the_send_csv_processing_first_stage_email_has_been_sent
    expect(SendCsvSubmittedForProcessingFirstStageEmailService).to have_received(:call)
      .with(
        upload: BulkUpdate::TraineeUpload.last,
      )
  end

  def and_i_visit_the_trainees_page
    visit trainees_path
  end

  def then_i_can_see_the_new_trainees
    expect(page).to have_content("Spencer Murphy")
    expect(page).to have_content(/Adrianne Ko(e|é)lpin/)
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
    expect(page).to have_content("Placement 2")
    expect(page).to have_content("URN 325900")
    expect(page).to have_content("Placement 3")
    expect(page).to have_content("URN 894261")

    expect(page).not_to have_content("First placement is missing")
    expect(page).not_to have_content("Second placement is missing")

    click_on "All records"

    click_on "Lavonda Bins"

    expect(page).to have_content("Placement 1")
    expect(page).to have_content("URN 773124")

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
    expect(page).to have_content("2010")

    click_on "All records"

    click_on "Bethanie Schumm"

    expect(page).to have_content("Non-UK Master of Social Studies: offshore engineering")
    expect(page).to have_content("Mexico")
    expect(page).to have_content("Offshore engineering")
    expect(page).to have_content("Master of Social Studies")
    expect(page).to have_content("2001")
  end

  def then_i_can_see_the_new_trainees_with_a_disability
    expect(page).to have_content("Preston Rath")
    expect(page).to have_content("Breanne Langosh")
    expect(page).to have_content("Kirby Gerlach")
    expect(page).to have_content("Emilio Rippin")
    expect(page).to have_content("Lavonda Bins")

    click_on "Preston Rath"

    expect(page).to have_content("deaf")
    expect(page).to have_content("blind")
    expect(page).to have_content("development condition")
    expect(page).to have_content("learning difficulty")
    expect(page).to have_content("long-standing illness")
    expect(page).to have_content("mental health condition")
    expect(page).to have_content("physical disability or mobility issue")
    expect(page).to have_content("social or communication impairment")
    expect(page).to have_content("other")
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

  def when_i_click_the_review_errors_link
    click_on "Review errors"
  end

  def then_i_see_the_review_errors_page(upload: BulkUpdate::TraineeUpload.last)
    expect(page).to have_content("Review errors for #{pluralize(upload.total_rows_with_errors, 'trainee')} in the CSV you uploaded")
    expect(page).to have_content("You cannot add new trainees if there is an error in their row in the CSV file")
  end

  def when_i_click_on_the_download_link
    click_on "Download your CSV file with errors indicated"
  end

  def then_i_receive_the_file
    expect(page.response_headers["content-type"]).to eq("text/csv")
    expect(page.response_headers["content-disposition"]).to include("attachment; filename=\"trainee-upload-errors-#{BulkUpdate::TraineeUpload.last.id}.csv\"")

    expect(parsed_download_content).to eq(parsed_file_with_two_failed_content)
  end

  def when_i_return_to_the_review_errors_page
    visit bulk_update_add_trainees_upload_path(BulkUpdate::TraineeUpload.last)
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
    click_on("Home")
  end

  def then_i_see_the_new_bulk_update_import_page
    expect(page).to have_content("You uploaded a CSV file with details of:")
    expect(page).to have_content("5 trainees who can be added")
    expect(page).to have_content("File uploaded")
  end

  def when_i_click_on_cancel_process_link
    click_on "Cancel process"
  end

  def parsed_file_with_two_failed_content
    CSV.parse(file_with_two_failed_content, headers: true).map(&:to_h)
  end

  def parsed_download_content
    CSV.parse(download_content, headers: true).map(&:to_h)
  end

  def file_with_two_failed_content
    file_content("bulk_update/trainee_uploads/failed_with_failed.csv")
  end

  def empty_file_with_headers_content
    file_content("bulk_update/trainee_uploads/empty_file_with_headers.csv")
  end

  def and_i_click_on_continue_button
    click_on "Continue to check trainee details"
  end

  def and_i_click_the_cancel_process_link
    click_on "Cancel bulk upload"
  end

  def when_there_are_multiple_uploads
    @upload3 = create(:bulk_update_trainee_upload, :succeeded, created_at: 15.days.ago, provider: current_user.organisation)
    @upload4 = create(:bulk_update_trainee_upload, :failed, created_at: 16.days.ago, provider: current_user.organisation)
    @upload2 = create(:bulk_update_trainee_upload, :succeeded, created_at: 5.days.ago, provider: current_user.organisation)
    @upload5 = create(:bulk_update_trainee_upload, :succeeded, created_at: 3.weeks.ago, provider: current_user.organisation)
    @upload1 = create(:bulk_update_trainee_upload, :pending, created_at: 5.minutes.ago, provider: current_user.organisation)
  end

  def then_i_see_the_uploads_in_descending_historical_order
    dates = within(".govuk-table") { find_all("a") }.map(&:text)
    expect(dates).to eq([@upload1, @upload2, @upload3, @upload4, @upload5].map(&:created_at).map { |date| date.to_fs(:govuk_date_and_time) })
  end

  alias_method :and_i_attach_a_valid_file, :when_i_attach_a_valid_file
  alias_method :and_i_click_the_submit_button, :when_i_click_the_submit_button
  alias_method :when_i_click_the_upload_button, :and_i_click_the_upload_button
  alias_method :and_i_visit_the_bulk_update_index_page, :when_i_visit_the_bulk_update_index_page
  alias_method :when_i_click_on_back_link, :and_i_click_on_back_link
  alias_method :and_i_click_the_view_status_of_new_trainee_files_link, :when_i_click_the_view_status_of_new_trainee_files_link
  alias_method :when_i_visit_the_bulk_update_index_page, :and_i_visit_the_bulk_update_index_page
  alias_method :and_i_click_on_an_upload, :when_i_click_on_an_upload
  alias_method :and_a_job_is_queued_to_process_the_upload, :then_a_job_is_queued_to_process_the_upload
  alias_method :and_the_background_job_is_run, :when_the_background_job_is_run
  alias_method :and_i_return_to_the_review_errors_page, :when_i_return_to_the_review_errors_page
  alias_method :and_i_visit_the_bulk_update_trainee_upload_page, :when_i_try_resubmit_the_same_upload
  alias_method :and_i_click_the_documentation_empty_csv_link, :when_i_click_the_documentation_empty_csv_link
  alias_method :and_i_click_the_guidance_link, :when_i_click_the_guidance_link
  alias_method :and_i_attach_an_empty_file, :when_i_attach_an_empty_file
  alias_method :when_i_visit_the_bulk_update_trainee_uploads_page, :and_i_visit_the_bulk_update_trainee_uploads_page
  alias_method :when_i_click_the_bulk_add_trainees_page, :and_i_click_the_bulk_add_trainees_page
  alias_method :and_i_see_instructions_on_how_to_bulk_add_trainees, :then_i_see_instructions_on_how_to_bulk_add_trainees
  alias_method :and_i_see_the_new_bulk_update_import_page, :then_i_see_the_new_bulk_update_import_page
  alias_method :when_i_visit_the_summary_page, :and_i_visit_the_summary_page
  alias_method :and_i_click_the_cancel_bulk_updates_link, :when_i_click_the_cancel_bulk_updates_link
  alias_method :then_i_see_file_validation_passed, :and_i_see_file_validation_passed
end
