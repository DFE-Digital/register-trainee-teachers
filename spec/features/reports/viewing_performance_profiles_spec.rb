# frozen_string_literal: true

require "rails_helper"

feature "viewing performance profiles" do
  let!(:previous_cycle) { create(:academic_cycle, previous_cycle: true) }
  let!(:current_cycle) { create(:academic_cycle, :current) }
  let!(:trainee) { create(:trainee, :trn_received, start_academic_cycle: previous_cycle, end_academic_cycle: previous_cycle) }

  context "inside sign-off period" do
    before { allow(Settings).to receive(:in_sign_off_period?).and_return(true) }

    background do
      given_i_am_authenticated
      given_i_am_on_the_reports_page
      and_i_click_the_performance_profiles_link
    end

    scenario "shows the correct year" do
      then_i_should_see_the_correct_performance_profiles_guidance
    end
  end

  context "outside sign-off period" do
    before { allow(Settings).to receive(:in_sign_off_period?).and_return(false) }

    background do
      given_i_am_authenticated
      given_i_am_on_the_reports_page
      and_i_click_the_performance_profiles_guidance_link
    end

    scenario "shows the correct content" do
      then_i_should_see_the_correct_performance_profiles_guidance_outside_of_sign_off_period
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

  def then_i_should_see_the_correct_performance_profiles_guidance
    expect(performance_profiles_page).to have_text(previous_cycle.label)
  end

  def then_i_should_see_the_correct_performance_profiles_guidance_outside_of_sign_off_period
    expect(performance_profiles_page).to have_text("Each year you need to sign off your list of trainee teachers from the previous academic year.")
  end
end
