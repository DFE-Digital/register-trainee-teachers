# frozen_string_literal: true

require "rails_helper"

feature "viewing reports index" do
  let!(:previous_academic_cycle) { AcademicCycle.previous }
  let!(:current_academic_cycle) { AcademicCycle.current }
  let(:performance_profile_sign_off_date) { previous_academic_cycle.end_date_of_performance_profile.strftime(Date::DATE_FORMATS[:govuk]) }
  let!(:trainee) { create(:trainee, :trn_received, start_academic_cycle: previous_academic_cycle, end_academic_cycle: previous_academic_cycle) }

  context "in the performance period" do
    before { allow(DetermineSignOffPeriod).to receive(:call).and_return(:performance_period) }

    background do
      given_i_am_authenticated
      given_i_am_on_the_reports_page
    end

    scenario "shows the correct content" do
      then_i_should_see_the_performance_period_content
    end

    context "the provider performance profile has been signed off" do
      let!(:user) { create(:user, providers: [build(:provider, sign_offs: [build(:sign_off, :performance_profile, academic_cycle: previous_academic_cycle)])]) }

      background do
        given_i_am_authenticated(user:)
        given_i_am_on_the_reports_page
      end

      scenario "shows the correct content" do
        then_i_should_see_the_outside_period_content
      end
    end
  end

  context "in the census period" do
    before { allow(DetermineSignOffPeriod).to receive(:call).and_return(:census_period) }

    background do
      given_i_am_authenticated
      given_i_am_on_the_reports_page
    end

    scenario "shows the correct content" do
      then_i_should_see_the_census_period_content
    end
  end

  context "outside of either period" do
    before { allow(DetermineSignOffPeriod).to receive(:call).and_return(:outside_period) }

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
    expect(reports_page).to have_text("Performance Profile")
    expect(reports_page).to have_text("Trainees who studied in the #{previous_academic_cycle.label} academic year report - for performance profiles sign off with a deadline of #{performance_profile_sign_off_date}")
  end

  def then_i_should_see_the_census_period_content
    expect(reports_page).not_to have_text("No reports are currently available.")
    expect(reports_page).to have_text("Census Sign Off")
    expect(reports_page).to have_text("New trainees for the #{current_academic_cycle.label} academic year - for census sign off")
    expect(reports_page).to have_text("Trainees who studied in the #{previous_academic_cycle.label} academic year - will be available for performance profiles sign off")
  end

  def then_i_should_see_the_outside_period_content
    expect(reports_page).to have_text("No reports are currently available.")
    expect(reports_page).not_to have_text("When they’re available, you’ll be able to download reports showing:")
  end
end
