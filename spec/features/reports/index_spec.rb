# frozen_string_literal: true

require "rails_helper"

feature "viewing reports index" do
  let!(:previous_cycle) { create(:academic_cycle, previous_cycle: true) }
  let!(:current_cycle) { create(:academic_cycle, :current) }
  let!(:trainee) { create(:trainee, :trn_received, start_academic_cycle: previous_cycle, end_academic_cycle: previous_cycle) }

  context "in the performance period" do
    before { allow(SignOffPeriodService).to receive(:call).and_return(:performance_period) }

    background do
      given_i_am_authenticated
      given_i_am_on_the_reports_page
    end

    scenario "shows the correct content" do
      then_i_should_see_the_performance_period_content
    end
  end

  context "in the census period" do
    before { allow(SignOffPeriodService).to receive(:call).and_return(:census_period) }

    background do
      given_i_am_authenticated
      given_i_am_on_the_reports_page
    end

    scenario "shows the correct content" do
      then_i_should_see_the_census_period_content
    end
  end

  context "outside of either period" do
    before { allow(SignOffPeriodService).to receive(:call).and_return(:outside_period) }

    background do
      given_i_am_authenticated
      given_i_am_on_the_reports_page
    end

    scenario "shows the correct content" do
      then_i_should_see_the_outside_period_content
    end
  end

private

  def given_i_am_on_the_reports_page
    reports_page.load
  end

  def and_i_click_the_performance_profiles_link
    reports_page.performance_profiles_link.click
  end

  def and_i_click_the_performance_profiles_guidance_link
    reports_page.performance_profiles_guidance_link.click
  end

  def then_i_should_see_the_performance_period_content
    expect(reports_page).not_to have_text("No reports are currently available.")
    expect(reports_page).to have_text("New trainees for the #{current_cycle.label} academic year - will be available for census sign off")
    expect(reports_page).to have_text("Trainees who studied in the #{previous_cycle.label} academic year - for performance profiles sign off")
  end

  def then_i_should_see_the_census_period_content
    expect(reports_page).not_to have_text("No reports are currently available.")
    expect(reports_page).to have_text("New trainees for the #{current_cycle.label} academic year - for census sign off")
    expect(reports_page).to have_text("Trainees who studied in the #{previous_cycle.label} academic year - will be available for performance profiles sign off")
  end

  def then_i_should_see_the_outside_period_content
    expect(reports_page).to have_text("No reports are currently available.")
    expect(reports_page).to have_text("When they’re available, you’ll be able to download reports showing:")
  end
end
