# frozen_string_literal: true

require "rails_helper"

feature "csv sandbox banner", feature_show_csv_sandbox_banner: true do
  context "not logged in" do
    scenario "csv sandbox banner is not shown" do
      given_i_am_not_logged_in
      when_i_am_on_the_root_page
      then_i_do_not_see_the_csv_sandbox_banner
    end
  end

  context "accredited provider user" do
    scenario "csv sandbox banner is shown" do
      given_i_am_authenticated
      when_i_am_on_the_root_page
      then_i_can_see_the_csv_sandbox_banner
    end
  end

private

  def when_i_am_on_the_root_page
    visit "/"
  end

  def given_i_am_not_logged_in; end

  def then_i_do_not_see_the_csv_sandbox_banner
    expect(page).not_to have_css(".govuk-notification-banner__heading", text: "CSV sandbox is for review and testing purposes only")
    expect(page).not_to have_css(".govuk-notification-banner__content .govuk-body", text: "You must not use real trainee data that contains personally identifiable information.")
    expect(page).not_to have_css(".govuk-notification-banner__content .govuk-body", text: "Send your feedback or questions to registertraineeteachers@education.gov.uk.")
  end

  def then_i_can_see_the_csv_sandbox_banner
    expect(page).to have_css(".govuk-notification-banner")

    expect(page).to have_css("#govuk-notification-banner-title", text: "Important")
    expect(page).to have_css(".govuk-notification-banner__heading", text: "CSV sandbox is for review and testing purposes only")
    expect(page).to have_css(".govuk-notification-banner__content .govuk-body", text: "You must not use real trainee data that contains personally identifiable information.")
    expect(page).to have_css(".govuk-notification-banner__content .govuk-body", text: "Send your feedback or questions to registertraineeteachers@education.gov.uk.")
  end
end
