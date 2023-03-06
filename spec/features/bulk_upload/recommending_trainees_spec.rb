# frozen_string_literal: true

require "rails_helper"

feature "recommending trainees" do
  before do
    given_i_am_authenticated
  end

  context "given no trainees exist to recommend" do
    scenario "I see 'no trainees' content" do
      given_i_am_on_the_recommendations_upload_page
      then_i_see_no_trainees_content
    end
  end

  context "given multiple trainees exist to recommend" do
    before do
      given_two_trainees_exist_to_recommend
      given_i_am_on_the_recommendations_upload_page
      then_i_see_how_many_trainees_i_can_recommend
    end

    context "and I upload a complete CSV" do
      scenario "I can upload trainees for recommendation" do
        and_i_upload_a_csv("bulk_update/recommendations_upload/complete.csv")
        then_i_see_count_complete
        and_i_check_who_ill_recommend
      end
    end

    context "and I upload a CSV missing dates" do
      scenario "I can upload trainees for recommendation" do
        and_i_upload_a_csv("bulk_update/recommendations_upload/missing_date.csv")
        then_i_see_count_missing_dates
        and_i_check_who_ill_recommend
      end
    end

    context "and I upload a CSV with no dates" do
      scenario "I am told to try again" do
        and_i_upload_a_csv("bulk_update/recommendations_upload/no_date.csv")
        then_i_see_no_dates_content
      end
    end
  end

private

  def given_i_am_on_the_recommendations_upload_page
    recommendations_upload_page.load
  end

  def given_two_trainees_exist_to_recommend
    create(:trainee, :trn_received, trn: "2413295", itt_end_date: Time.zone.today, provider: current_user.organisation)
    create(:trainee, :trn_received, trn: "4814731", itt_end_date: Time.zone.today + 1.month, provider: current_user.organisation)
  end

  def then_i_see_how_many_trainees_i_can_recommend
    expect(recommendations_upload_page).to have_text("2 trainees")
  end

  def then_i_see_no_trainees_content
    expect(recommendations_upload_page).to have_text("You do not have any trainees")
  end

  def and_i_upload_a_csv(csv_path)
    attach_file("bulk_update_recommendations_upload_form[file]", file_fixture(csv_path).to_path)
    recommendations_upload_page.upload_button.click
    expect(BulkUpdate::RecommendationsUploadRow.count).to be 2
  end

  def and_i_check_who_ill_recommend
    recommendations_upload_show_page.check_button.click
  end

  def then_i_see_count_complete
    expect(recommendations_upload_show_page).to have_text("2 trainees who will be recommended")
  end

  def then_i_see_count_missing_dates
    expect(recommendations_upload_show_page).to have_text("1 trainee who will be recommended")
    expect(recommendations_upload_show_page).to have_text("1 trainee who will not be recommended")
  end

  def then_i_see_no_dates_content
    expect(recommendations_upload_show_page).to have_text("You did not enter any dates")
  end
end
