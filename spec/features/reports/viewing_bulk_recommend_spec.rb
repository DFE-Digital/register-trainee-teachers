# frozen_string_literal: true

require "rails_helper"

feature "viewing bulk QTS" do
  let(:itt_start_date) { 2.years.ago }
  let(:itt_end_date) { Time.zone.today }

  before do
    create(:academic_cycle, previous_cycle: true)
    create(:academic_cycle, :current)
  end

  background do
    given_i_am_authenticated
    given_trainees_exist
    given_i_am_on_the_reports_page
    and_i_click_the_bulk_recommend_link
  end

  scenario "shows the correct count of trainees" do
    then_i_should_see_the_correct_bulk_recommend_guidance
  end

private

  # only the first trainee should be retrieved.
  def given_trainees_exist
    given_a_trainee_exists(:trn_received, itt_start_date:, itt_end_date:)
    given_a_trainee_exists(:draft)
    given_a_trainee_exists(:trn_received, itt_start_date: itt_start_date, itt_end_date: itt_end_date + 7.months)
  end

  def given_i_am_on_the_reports_page
    reports_page.load
  end

  def and_i_click_the_bulk_recommend_link
    reports_page.bulk_recommend_link.click
  end

  def then_i_should_see_the_correct_bulk_recommend_guidance
    expect(bulk_recommend_page).to have_text("Trainees you can bulk recommend for QTS or EYTS")
    expect(bulk_recommend_page).to have_text("This export includes the details of 1 trainees")
    expect(bulk_recommend_page).to have_text("Export trainee data (1 trainees)")
  end
end
