# frozen_string_literal: true

require "rails_helper"

feature "recommending trainees" do
  before do
    given_i_am_authenticated
  end

  context "given no trainees exist to recommend" do
    scenario "i see 'no trainees' content" do
      given_i_am_on_the_recommendations_upload_page
      then_i_see_no_trainees_content
    end
  end

  context "given multiple trainees exist to recommend" do
    before do
      given_multiple_trainees_exist_to_recommend
    end

    scenario "i can upload trainees for recommendation" do
      given_i_am_on_the_recommendations_upload_page
      then_i_see_how_many_trainees_i_can_recommend
      and_i_upload_a_csv
    end
  end

private

  def given_i_am_on_the_recommendations_upload_page
    recommendations_upload_page.load
  end

  def given_multiple_trainees_exist_to_recommend
    create(:trainee, :trn_received, itt_end_date: Time.zone.today, provider: current_user.organisation)
    create(:trainee, :trn_received, itt_end_date: Time.zone.today + 1.month, provider: current_user.organisation)
  end

  def then_i_see_how_many_trainees_i_can_recommend
    expect(recommendations_upload_page).to have_text("2 trainees")
  end

  def then_i_see_no_trainees_content
    expect(recommendations_upload_page).to have_text("You do not have any trainees")
  end

  def and_i_upload_a_csv
    attach_file("bulk_update_recommendations_upload_form[file]", file_fixture("bulk_update/recommendations_upload/complete.csv").to_path)
    recommendations_upload_page.upload_button.click
    expect(BulkUpdate::RecommendedTrainee.count).to be 2
  end

  def and_i_check_who_ill_recommend
    recommendation_upload_show_page.check_button.click
  end
end
