# frozen_string_literal: true

require "rails_helper"

feature "Footer" do
  scenario "A User can see the footer links" do
    visit root_path

    within(".govuk-footer") do
      expect(page).to have_link(
        "News and updates", href: "/service-updates"
      )
      expect(page).to have_link(
        "How to use this service", href: "/guidance"
      )
      expect(page).to have_link(
        "API documentation", href: "/api-docs/"
      )
      expect(page).to have_link(
        "CSV documentation", href: "/csv-docs/"
      )
      expect(page).to have_link(
        "Accessibility", href: "/accessibility-statement"
      )
      expect(page).to have_link(
        "Cookies", href: "/cookies"
      )
      expect(page).to have_link(
        "Privacy", href: "/privacy-notice"
      )
      expect(page).to have_link(
        "Give feedback to help us improve Register trainee teachers",
        href: "https://forms.office.com/e/Q6LVwtEKje"
      )
      expect(page).to have_link(
        "becomingateacher@digital.education.gov.uk",
        href: "mailto:becomingateacher@digital.education.gov.uk"
      )
      expect(page).to have_content(
        "We aim to respond within 5 working days, or one working day for more urgent queries"
      )
    end
  end
end
