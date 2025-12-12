# frozen_string_literal: true

require "rails_helper"

feature "performance profile banner" do
  before do
    disable_features(:maintenance_banner)
  end

  context "within the performance profile date range" do
    background do
      allow(DetermineSignOffPeriod).to receive(:call).and_return(:performance_period)
      Timecop.freeze(AcademicCycle.previous.performance_profile_date_range.to_a.sample)
    end

    context "not logged in" do
      scenario "performance profile banner is not shown" do
        given_i_am_not_logged_in
        when_i_am_on_the_root_page
        then_i_do_not_see_the_performance_profile_banner
      end
    end

    context "logged in as system admin" do
      scenario "performance profile banner is not shown" do
        given_i_am_authenticated_as_system_admin
        when_i_am_on_the_root_page
        then_i_do_not_see_the_performance_profile_banner
      end
    end

    context "accredited provider user" do
      scenario "performance profile banner is shown" do
        given_i_am_authenticated
        when_i_am_on_the_root_page
        then_i_can_see_the_performance_profile_banner
        and_i_click_on("Sign off your performance profile")
        and_i_am_on_the_sign_off_your_performance_profile_page
      end
    end

    context "lead provider user" do
      scenario "performance profile banner is not shown" do
        given_i_am_authenticated_as_a_training_partner_user
        when_i_am_on_the_root_page
        then_i_do_not_see_the_performance_profile_banner
      end
    end
  end

private

  def when_i_am_on_the_root_page
    visit "/"
  end

  def given_i_am_not_logged_in; end

  def then_i_do_not_see_the_performance_profile_banner
    expect(page).not_to have_css("#govuk-notification-banner-title", text: "Important")
    expect(page).not_to have_css(".govuk-notification-banner__heading", text: "The #{previous_academic_cycle_label} ITT performance profile sign off is due")
  end

  def then_i_can_see_the_performance_profile_banner
    expect(page).to have_css("#govuk-notification-banner-title", text: "Important")
    expect(page).to have_css(".govuk-notification-banner__heading", text: "The #{previous_academic_cycle_label} ITT performance profile sign off is due")
  end

  def previous_academic_cycle_label
    AcademicCycle.previous.label
  end

  def and_i_am_on_the_sign_off_your_performance_profile_page
    expect(page).to have_current_path("/reports/performance-profiles")
  end

  alias_method :and_i_click_on, :click_on
end
