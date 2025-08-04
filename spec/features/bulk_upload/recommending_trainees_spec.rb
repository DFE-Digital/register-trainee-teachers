# frozen_string_literal: true

require "rails_helper"

feature "recommending trainees" do
  include RecommendationsUploadHelper

  before do
    given_i_am_authenticated
  end

  let(:write_to_disk) { true }
  let(:overwrite) do # one valid date for each trainee created in `given_two_trainees_exist_to_recommend`
    [
      { Reports::BulkRecommendReport::DATE => Time.zone.today.strftime("%d/%m/%Y") },
      { Reports::BulkRecommendReport::DATE => Time.zone.today.strftime("%d/%m/%Y") },
    ]
  end

  context "given multiple trainees exist to recommend" do
    before do
      given_two_trainees_exist_to_recommend
      given_i_am_on_the_recommendations_upload_page
    end

    context "when I use the empty template" do
      before do
        then_i_see_the_option_to_download_the_empty_template
        and_i_upload_a_csv(
          create_simplified_recommendations_upload_csv!(
            trainees: @trainees,
            write_to_disk: true,
            recommended_for_award_date: Time.zone.today,
          ),
        )
        and_i_can_see_that_i_have_two_trainees_to_recommend
      end

      context "and I upload a complete CSV" do
        scenario "I can upload trainees for recommendation" do
          then_i_see_count_complete
          and_i_check_who_ill_recommend
          and_i_see_a_list_of_trainees_to_check
          and_i_click_recommend
          then_i_see_the_confirmation
        end
      end
    end

    context "when I use the pre-populated template" do
      before do
        then_i_see_how_many_trainees_i_can_recommend
        file_name = create_recommendations_upload_csv!(write_to_disk:, overwrite:)
        and_i_upload_a_csv(file_name)
        and_i_can_see_that_i_have_two_trainees_to_recommend
      end

      context "and I upload a complete CSV" do
        scenario "I can upload trainees for recommendation" do
          then_i_see_count_complete
          and_i_check_who_ill_recommend
          and_i_see_a_list_of_trainees_to_check
          and_i_click_recommend
          then_i_see_the_confirmation
        end

        scenario "I can cancel my upload" do
          and_i_click_cancel
          and_i_click_confirm_cancel
          then_i_am_taken_back_to_the_upload_page
        end
      end

      context "and I upload a CSV missing dates" do
        let(:overwrite) do # a valid date for the first trainee created in `given_two_trainees_exist_to_recommend`
          [
            { Reports::BulkRecommendReport::DATE => Time.zone.today.strftime("%d/%m/%Y") },
          ]
        end

        scenario "I can upload trainees for recommendation" do
          then_i_see_count_missing_dates
          and_i_check_who_ill_recommend
        end
      end

      context "I can change who I want to recommend" do
        scenario "I see the form to change upload" do
          and_i_check_who_ill_recommend
          and_i_click_change_link
          then_i_see_the_form_to_change_upload
        end

        scenario "I get redirected to the correct page when no CSV is uploaded" do
          and_i_check_who_ill_recommend
          and_i_click_change_link
          then_i_see_the_form_to_change_upload
          and_i_submit_form_with_no_file
          then_i_see_validation_errors
          and_i_remain_on_the_change_upload_page
        end
      end

      context "and I upload a CSV with an error" do
        let(:overwrite) do # one valid, and one invalid date for trainees created in `given_two_trainees_exist_to_recommend`
          [
            { Reports::BulkRecommendReport::DATE => Date.tomorrow.strftime("%d/%m/%Y") },
            { Reports::BulkRecommendReport::DATE => Time.zone.today.strftime("%d/%m/%Y") },
          ]
        end

        scenario "I am shown the error count and am told to fix errors" do
          then_i_see_count_errors
          then_i_click_review_errors
          when_i_submit_form_with_no_file_attached
          then_i_see_validation_errors
        end
      end
    end

    context "when I try to upload an invalid CSV" do
      before do
        then_i_see_how_many_trainees_i_can_recommend
      end

      scenario "I cannot upload trainees for recommendation" do
        and_i_upload_a_csv(create_invalid_recommendations_upload_csv)
        then_i_see_an_error_message_about_file_encoding
      end
    end
  end

  context "given multiple trainees exist to recommend with duplicates" do
    before do
      given_two_trainees_exist_to_recommend
      and_a_duplicate_trainee_exists
      given_i_am_on_the_recommendations_upload_page
    end

    context "when I use the empty template" do
      before do
        then_i_see_the_option_to_download_the_empty_template
        and_i_upload_a_csv(
          create_simplified_recommendations_upload_csv!(
            trainees: @trainees,
            write_to_disk: true,
            recommended_for_award_date: Time.zone.today,
          ),
        )
        and_i_can_see_that_i_have_two_trainees_to_recommend
      end

      context "and I upload a complete CSV" do
        scenario "I can upload trainees for recommendation" do
          then_i_see_count_complete
          and_i_check_who_ill_recommend
          and_i_see_a_list_of_trainees_to_check
          and_i_click_recommend
          then_i_see_the_confirmation
        end
      end
    end
  end

private

  def given_i_am_on_the_recommendations_upload_page
    recommendations_upload_page.load
  end

  def given_two_trainees_exist_to_recommend
    @trainees = [
      create(:trainee, :trn_received, trn: "2413295", itt_end_date: Time.zone.today, provider: current_user.organisation),
      create(:trainee, :trn_received, trn: "4814731", itt_end_date: Time.zone.today + 1.month, provider: current_user.organisation),
    ]
  end

  def and_a_duplicate_trainee_exists
    @duplicate_trainee = create(:trainee, :trn_received, trn: "2413295", discarded_at: 1.day.ago, itt_end_date: Time.zone.today, provider: current_user.organisation)
  end

  def then_i_see_how_many_trainees_i_can_recommend
    expect(recommendations_upload_page).to have_text("2 trainees")
  end

  def then_i_see_the_option_to_download_the_empty_template
    expect(recommendations_upload_page).to have_link("Download an empty template file to recommend trainees for QTS or EYTS")
  end

  def and_i_upload_a_csv(csv_path)
    attach_file("bulk_update_recommendations_upload_form[file]", csv_path)
    recommendations_upload_page.upload_button.click
  end

  def and_i_can_see_that_i_have_two_trainees_to_recommend
    expect(BulkUpdate::RecommendationsUploadRow.count).to be 2
  end

  def and_i_check_who_ill_recommend
    recommendations_upload_show_page.check_button.click
  end

  def and_i_click_recommend
    recommendations_upload_show_page.recommend_button.click
  end

  def and_i_click_change_link
    recommendations_checks_show_page.change_link.click
  end

  def and_i_click_cancel
    recommendations_upload_show_page.cancel_link.click
  end

  def and_i_click_confirm_cancel
    recommendations_upload_cancel_page.confirm_button.click
  end

  def then_i_see_count_complete
    expect(recommendations_upload_show_page).to have_text("Both trainees will be recommended")
  end

  def then_i_see_count_missing_dates
    expect(recommendations_upload_show_page).to have_text("1 trainee who will be recommended")
    expect(recommendations_upload_show_page).to have_text("1 trainee who will not be recommended")
  end

  def then_i_see_the_form_to_change_upload
    expect(edit_recommendations_upload_page).to be_displayed
  end

  def then_i_see_count_errors
    expect(recommendations_upload_show_page).to have_text("1 trainee with errors")
  end

  def then_i_click_review_errors
    recommendations_upload_show_page.review_errors_button.click
  end

  def then_i_can_fix_my_errors
    recommendations_upload_fix_errors_page.to have_text("Review errors for 1 trainee in the CSV file you uploaded")
  end

  def then_i_am_taken_back_to_the_upload_page
    expect(recommendations_upload_page).to be_displayed
  end

  def when_i_submit_form_with_no_file_attached
    recommendations_checks_show_page.upload_button.click
  end
  alias and_i_submit_form_with_no_file when_i_submit_form_with_no_file_attached

  def then_i_see_validation_errors
    expect(recommendations_checks_show_page).to have_text("Select a CSV file")
  end

  def and_i_remain_on_the_change_upload_page
    expect(recommendations_checks_show_page).to have_text("Change who you’ll recommend for QTS or EYTS")
  end

  def and_i_see_a_list_of_trainees_to_check
    @trainees.each do |trainee|
      training_route = t("activerecord.attributes.trainee.training_routes.#{trainee.training_route}")
      expect(recommendations_checks_show_page).to have_text("#{trainee.first_names} #{trainee.last_name}")
      expect(recommendations_checks_show_page).to have_text("TRN: #{trainee.trn}")
      expect(recommendations_checks_show_page).to have_text(training_route)
    end
  end

  def then_i_see_an_error_message_about_file_encoding
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("The uploaded file is in an unsupported file encoding")
  end

  def then_i_see_the_confirmation
    expect(recommendations_upload_confirmation_page).to have_content("2 trainees recommended for QTS")
  end
end
