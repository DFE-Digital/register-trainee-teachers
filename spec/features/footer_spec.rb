# frozen_string_literal: true

require "rails_helper"

feature "Footer" do
  before do
    visit root_path
  end

  context "when the API and CSV features are disabled" do
    scenario "A User can see the footer links", feature_bulk_add_trainees: false, feature_register_api: false do
      within(".govuk-footer") do
        i_see_the_news_and_updates_link
        and_i_see_the_how_to_use_this_service_link
        and_i_dont_see_the_api_docs_link
        and_i_dont_see_the_csv_docs_link
        and_i_see_the_reference_data_link
        and_i_see_the_accessibility_link
        and_i_see_the_cookies_link
        and_i_see_privacy_link
        and_i_see_the_give_feedback_link
        and_i_see_the_email_link
      end
    end
  end

  context "when the API feature is enabled" do
    scenario "A User can see the api-docs link", feature_bulk_add_trainees: false, feature_register_api: true do
      within(".govuk-footer") do
        i_see_the_news_and_updates_link
        and_i_see_the_how_to_use_this_service_link
        and_i_see_the_api_docs_link
        and_i_dont_see_the_csv_docs_link
        and_i_see_the_reference_data_link
        and_i_see_the_accessibility_link
        and_i_see_the_cookies_link
        and_i_see_privacy_link
        and_i_see_the_give_feedback_link
        and_i_see_the_email_link
      end
    end
  end

  context "when the CSV feature is enabled" do
    scenario "A User can see the csv-docs link", feature_bulk_add_trainees: true, feature_register_api: false do
      within(".govuk-footer") do
        i_see_the_news_and_updates_link
        and_i_see_the_how_to_use_this_service_link
        and_i_see_the_reference_data_link
        and_i_dont_see_the_api_docs_link
        and_i_see_the_csv_docs_link
        and_i_see_the_reference_data_link
        and_i_see_the_accessibility_link
        and_i_see_the_cookies_link
        and_i_see_privacy_link
        and_i_see_the_give_feedback_link
        and_i_see_the_email_link
      end
    end
  end

  context "when the API and CSV features are enabled", feature_bulk_add_trainees: true, feature_register_api: true do
    scenario "A User can see the api-docs and csv-docs links" do
      within(".govuk-footer") do
        i_see_the_news_and_updates_link
        and_i_see_the_how_to_use_this_service_link
        and_i_see_the_reference_data_link
        and_i_see_the_api_docs_link
        and_i_see_the_csv_docs_link
        and_i_see_the_reference_data_link
        and_i_see_the_accessibility_link
        and_i_see_the_cookies_link
        and_i_see_privacy_link
        and_i_see_the_give_feedback_link
        and_i_see_the_email_link
      end
    end
  end

private

  def i_see_the_news_and_updates_link
    expect(page).to have_link(
      "News and updates", href: "/service-updates"
    )
  end

  def and_i_see_the_how_to_use_this_service_link
    expect(page).to have_link(
      "How to use this service", href: "/guidance"
    )
  end

  def and_i_see_the_api_docs_link
    expect(page).to have_link(
      "API documentation", href: "/api-docs/"
    )
  end

  def and_i_dont_see_the_api_docs_link
    expect(page).not_to have_link(
      "API documentation", href: "/api-docs/"
    )
  end

  def and_i_see_the_csv_docs_link
    expect(page).to have_link(
      "CSV documentation", href: "/csv-docs/"
    )
  end

  def and_i_dont_see_the_csv_docs_link
    expect(page).not_to have_link(
      "CSV documentation", href: "/csv-docs/"
    )
  end

  def and_i_see_the_reference_data_link
    expect(page).to have_link(
      "Reference data", href: "/reference-data/"
    )
  end

  def and_i_see_the_accessibility_link
    expect(page).to have_link(
      "Accessibility", href: "/accessibility"
    )
  end

  def and_i_see_the_cookies_link
    expect(page).to have_link(
      "Cookies", href: "/cookies"
    )
  end

  def and_i_see_privacy_link
    expect(page).to have_link(
      "Privacy", href: "/privacy-notice"
    )
  end

  def and_i_see_the_give_feedback_link
    expect(page).to have_link(
      "Give feedback to help us improve Register trainee teachers",
      href: "https://forms.office.com/e/Q6LVwtEKje",
    )
  end

  def and_i_see_the_email_link
    expect(page).to have_content("Email: becomingateacher@digital.education.gov.uk")
    expect(page).to have_link(
      "becomingateacher@digital.education.gov.uk",
      href: "mailto:becomingateacher@digital.education.gov.uk",
    )
    expect(page).to have_content(
      "We aim to respond within 5 working days, or one working day for more urgent queries",
    )
  end
end
