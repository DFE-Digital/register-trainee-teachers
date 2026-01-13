# frozen_string_literal: true

require "rails_helper"

feature "performance profile sign off" do
  before do
    disable_features(:maintenance_banner)
  end

  context "outside period" do
    background do
      allow(DetermineSignOffPeriod).to receive(:call).and_return(:outside_period)
    end

    scenario "navigate to the sign off your performance profile page" do
      given_i_am_authenticated
      when_i_visit_the_sign_off_your_performance_profile_page
      then_i_am_redirected_to_the_reports_page
    end

    scenario "navigate to the itt performance profile sign off for the academic year page" do
      given_i_am_authenticated
      when_i_visit_the_itt_performance_profile_sign_off_for_the_academic_year_page
      then_i_am_redirected_to_the_reports_page
    end
  end

  context "performance period" do
    background do
      allow(DetermineSignOffPeriod).to receive(:call).and_return(:performance_period)
    end

    context "accredited provider user" do
      scenario "navigate to the performance profile confirmation page" do
        given_i_am_authenticated
        when_i_visit_the_performance_profile_confirmation_page
        then_i_am_redirected_to_the_reports_page
      end

      scenario "user signing off the performance profile from banner" do
        given_i_am_authenticated
        and_i_am_on_the_root_page
        and_i_can_see_the_performance_profile_banner
        and_i_click_on("Sign off your performance profile")
        and_i_am_on_the_sign_off_your_performance_profile_page

        when_i_click_on("Continue to performance profile sign off")
        and_i_am_on_the_itt_performance_profile_sign_off_for_the_academic_year_page
        and_i_can_see_the_performance_profile_information
        and_i_click_on("Sign off performance profile")
        and_i_see_there_is_a_problem
        and_i_click_on("Confirm sign off")
        and_i_check_on("Yes, the trainee data is correct to the best of my knowledge")
        and_i_click_on("Sign off performance profile")

        then_i_am_on_the_performance_profile_confirmation_page
        and_the_provider_has_performance_profile_signed_off
      end

      scenario "user signing off the performance profile from reports page" do
        given_i_am_authenticated
        and_i_am_on_the_reports_page
        and_i_click_on("Trainees who studied in the #{previous_academic_cycle_label} academic year report")
        and_i_am_on_the_sign_off_your_performance_profile_page

        when_i_click_on("Continue to performance profile sign off")
        and_i_am_on_the_itt_performance_profile_sign_off_for_the_academic_year_page
        and_i_can_see_the_performance_profile_information
        and_i_am_on_the_itt_performance_profile_sign_off_for_the_academic_year_page
        and_i_check_on("Yes, the trainee data is correct to the best of my knowledge")
        and_i_click_on("Sign off performance profile")

        then_i_am_on_the_performance_profile_confirmation_page
        and_the_provider_has_performance_profile_signed_off
      end

      scenario "a previously accredited provider signing off the performance profile from reports page" do
        given_i_am_authenticated(user: create(:user, providers: [build(:provider, :unaccredited)]))
        and_i_am_on_the_reports_page

        and_i_click_on("Trainees who studied in the #{previous_academic_cycle_label} academic year report")
        and_i_am_on_the_sign_off_your_performance_profile_page

        when_i_click_on("Continue to performance profile sign off")
        and_i_am_on_the_itt_performance_profile_sign_off_for_the_academic_year_page
        and_i_can_see_the_performance_profile_information
        and_i_am_on_the_itt_performance_profile_sign_off_for_the_academic_year_page
        and_i_check_on("Yes, the trainee data is correct to the best of my knowledge")
        and_i_click_on("Sign off performance profile")

        then_i_am_on_the_performance_profile_confirmation_page
        and_the_provider_has_performance_profile_signed_off
      end

      context "performance profile signed off" do
        scenario "sign off your performance profile page" do
          given_i_am_authenticated
          and_provider_has_performance_profile_signed_off

          when_i_visit_the_sign_off_your_performance_profile_page
          then_i_am_redirected_to_the_reports_page
        end

        scenario "itt performance profile sign off for the academic year page" do
          given_i_am_authenticated
          and_provider_has_performance_profile_signed_off

          when_i_visit_the_itt_performance_profile_sign_off_for_the_academic_year_page
          then_i_am_redirected_to_the_reports_page
        end
      end
    end

    context "lead provider user" do
      scenario "unauthorized message is shown" do
        given_i_am_authenticated_as_a_training_partner_user
        when_i_visit_the_sign_off_your_performance_profile_page
        then_i_see_the_unauthorized_message
      end
    end

    context "system admin with no associated provider" do
      scenario "system administrator account banner message is shown" do
        given_i_am_authenticated_as_system_admin
        when_i_visit_the_sign_off_your_performance_profile_page
        then_i_see_the_system_administrator_account_banner
      end
    end
  end

private

  def previous_academic_cycle_label
    AcademicCycle.previous.label
  end

  def and_the_provider_has_performance_profile_signed_off
    expect(SignOff.exists?(academic_cycle: AcademicCycle.previous, sign_off_type: :performance_profile, user: current_user, provider: current_user.providers.first)).to be_truthy
  end

  def and_provider_has_performance_profile_signed_off
    SignOff.new(academic_cycle: AcademicCycle.previous, sign_off_type: :performance_profile, user: current_user, provider: current_user.providers.first).save!
  end

  def and_i_am_on_the_itt_performance_profile_sign_off_for_the_academic_year_page
    expect(page).to have_current_path("/reports/performance-profiles/new")
  end

  def then_i_am_on_the_performance_profile_confirmation_page
    expect(page).to have_current_path("/reports/performance-profiles/confirmation")
  end

  def and_i_can_see_the_performance_profile_information
    expect(page).to have_css(".govuk-heading-l", text: "ITT performance profile sign off for the #{previous_academic_cycle_label} academic year")

    expect(page).to have_css(".govuk-summary-card__title", text: "Performance profile information")

    expect(page).to have_css(".govuk-summary-list__key", text: "Provider name")
    expect(page).to have_css(".govuk-summary-list__value", text: current_user.providers.first.name)

    expect(page).to have_css(".govuk-summary-list__key", text: "UKPRN")
    expect(page).to have_css(".govuk-summary-list__value", text: current_user.providers.first.ukprn)

    expect(page).to have_css(".govuk-summary-list__key", text: "Approver name")
    expect(page).to have_css(".govuk-summary-list__value", text: current_user.name)
  end

  def and_i_am_on_the_root_page
    visit "/"
  end

  def and_i_am_on_the_reports_page
    visit "/reports"
  end

  def and_i_can_see_the_performance_profile_banner
    expect(page).to have_css("#govuk-notification-banner-title", text: "Important")
    expect(page).to have_css(".govuk-notification-banner__heading", text: "The #{previous_academic_cycle_label} ITT performance profile sign off is due")
  end

  def previous_academic_cycle_label
    AcademicCycle.previous.label
  end

  def and_i_am_on_the_sign_off_your_performance_profile_page
    expect(page).to have_current_path("/reports/performance-profiles")
  end

  def when_i_visit_the_itt_performance_profile_sign_off_for_the_academic_year_page
    visit("/reports/performance-profiles/new")
  end

  def when_i_visit_the_sign_off_your_performance_profile_page
    visit "/reports/performance-profiles"
  end

  def when_i_visit_the_performance_profile_confirmation_page
    visit "/reports/performance-profiles/confirmation"
  end

  def then_i_am_redirected_to_the_reports_page
    expect(page).to have_current_path("/reports")
  end

  def then_i_see_the_unauthorized_message
    expect(page).to have_content("You do not have permission to perform this action")
  end

  def then_i_see_the_system_administrator_account_banner
    expect(page).to have_css("#govuk-notification-banner-title", text: "Important")
    expect(page).to have_css(".govuk-notification-banner__heading", text: "Your system administrator account must be associated with an accredited provider")
    expect(page).to have_css(".govuk-notification-banner__content", text: "You can edit your user details")

    expect(page).to have_link("user details", href: "/system-admin/users/#{@current_user.id}")
  end

  def and_i_see_there_is_a_problem
    expect(page).to have_css(".govuk-error-summary__title", text: "There is a problem")
  end

  alias_method :and_i_check_on, :check
  alias_method :and_i_click_on, :click_on
  alias_method :when_i_click_on, :click_on
end
