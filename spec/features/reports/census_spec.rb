# frozen_string_literal: true

require "rails_helper"

feature "census sign off" do
  context "outside period" do
    background do
      allow(DetermineSignOffPeriod).to receive(:call).and_return(:outside_period)
    end

    scenario "navigate to the sign off your census page" do
      given_i_am_authenticated
      when_i_visit_the_sign_off_your_census_page
      then_i_am_redirected_to_the_reports_page
    end

    scenario "navigate to the itt census sign off for the page" do
      given_i_am_authenticated
      when_i_visit_the_itt_census_sign_off_for_the_academic_year_page
      then_i_am_redirected_to_the_reports_page
    end
  end

  context "census period" do
    background do
      allow(DetermineSignOffPeriod).to receive(:call).and_return(:census_period)
    end

    context "accredited provider user" do
      scenario "navigate to the census confirmation page" do
        given_i_am_authenticated
        when_i_visit_the_census_confirmation_page
        then_i_am_redirected_to_the_reports_page
      end

      scenario "user signing off the census from banner" do
        given_i_am_authenticated
        and_i_am_on_the_root_page
        and_i_can_see_the_census_banner
        and_i_click_on("Sign off your census")
        and_i_am_on_the_sign_off_your_census_page

        when_i_click_on("Continue to census sign off")
        and_i_am_on_the_itt_census_sign_off_for_the_academic_year_page
        and_i_can_see_the_census_information
        and_i_click_on("Sign off census")
        and_i_check_on("Yes, the trainee data is correct to the best of my knowledge")
        and_i_click_on("Sign off census")

        then_i_am_on_the_census_confirmation_page
        and_the_provider_has_census_signed_off
      end

      scenario "user signing off the census from reports page" do
        given_i_am_authenticated
        and_i_am_on_the_reports_page
        and_i_click_on("Trainees with their academic start year in #{current_academic_cycle_label} report")
        and_i_am_on_the_sign_off_your_census_page

        when_i_click_on("Continue to census sign off")
        and_i_am_on_the_itt_census_sign_off_for_the_academic_year_page
        and_i_can_see_the_census_information
        and_i_am_on_the_itt_census_sign_off_for_the_academic_year_page
        and_i_check_on("Yes, the trainee data is correct to the best of my knowledge")
        and_i_click_on("Sign off census")

        then_i_am_on_the_census_confirmation_page
        and_the_provider_has_census_signed_off
      end

      scenario "a previously accredited provider signing off the census from reports page" do
        given_i_am_authenticated(user: create(:user, providers: [build(:provider, :unaccredited)]))
        and_i_am_on_the_reports_page

        and_i_click_on("Trainees with their academic start year in #{current_academic_cycle_label} report")
        and_i_am_on_the_sign_off_your_census_page

        when_i_click_on("Continue to census sign off")
        and_i_am_on_the_itt_census_sign_off_for_the_academic_year_page
        and_i_can_see_the_census_information
        and_i_am_on_the_itt_census_sign_off_for_the_academic_year_page
        and_i_check_on("Yes, the trainee data is correct to the best of my knowledge")
        and_i_click_on("Sign off census")

        then_i_am_on_the_census_confirmation_page
        and_the_provider_has_census_signed_off
      end

      context "census signed off" do
        scenario "sign off your census page" do
          given_i_am_authenticated
          and_provider_has_census_signed_off

          when_i_visit_the_sign_off_your_census_page
          then_i_am_redirected_to_the_reports_page
        end

        scenario "itt census sign off for the page" do
          given_i_am_authenticated
          and_provider_has_census_signed_off

          when_i_visit_the_itt_census_sign_off_for_the_academic_year_page
          then_i_am_redirected_to_the_reports_page
        end
      end
    end

    context "lead provider user" do
      scenario "unauthorized message is shown" do
        given_i_am_authenticated_as_a_lead_partner_user
        when_i_visit_the_sign_off_your_census_page
        then_i_see_the_unauthorized_message
      end
    end

    context "system admin with no associated provider" do
      scenario "system administrator account banner message is shown" do
        given_i_am_authenticated_as_system_admin
        when_i_visit_the_sign_off_your_census_page
        then_i_see_the_system_administrator_account_banner
      end
    end
  end

private

  def current_academic_cycle_label
    AcademicCycle.current.label
  end

  def and_the_provider_has_census_signed_off
    expect(SignOff.exists?(academic_cycle: AcademicCycle.current, sign_off_type: :census, user: current_user, provider: current_user.providers.first)).to be_truthy
  end

  def and_provider_has_census_signed_off
    SignOff.new(academic_cycle: AcademicCycle.current, sign_off_type: :census, user: current_user, provider: current_user.providers.first).save!
  end

  def and_i_am_on_the_itt_census_sign_off_for_the_academic_year_page
    expect(page).to have_current_path("/reports/censuses/new")
  end

  def then_i_am_on_the_census_confirmation_page
    expect(page).to have_current_path("/reports/censuses/confirmation")
  end

  def and_i_can_see_the_census_information
    expect(page).to have_css(".govuk-heading-l", text: "Census sign off your organisation’s new trainee data for the #{current_academic_cycle_label} academic year")

    expect(page).to have_css(".govuk-summary-card__title", text: "Census sign off information")

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

  def and_i_can_see_the_census_banner
    expect(page).to have_css("#govuk-notification-banner-title", text: "Important")
    expect(page).to have_css(".govuk-notification-banner__heading", text: "The #{current_academic_cycle_label} ITT census sign off is due")
  end

  def current_academic_cycle_label
    AcademicCycle.current.label
  end

  def and_i_am_on_the_sign_off_your_census_page
    expect(page).to have_current_path("/reports/censuses")
  end

  def when_i_visit_the_itt_census_sign_off_for_the_academic_year_page
    visit("/reports/censuses/new")
  end

  def when_i_visit_the_sign_off_your_census_page
    visit "/reports/censuses"
  end

  def when_i_visit_the_census_confirmation_page
    visit "/reports/censuses/confirmation"
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
