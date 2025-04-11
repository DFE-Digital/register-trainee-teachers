# frozen_string_literal: true

require "rails_helper"

describe CsvSandboxBanner::View do
  before do
    render_inline(described_class.new)
  end

  context "show_csv_sandbox_banner is false", feature_show_csv_sandbox_banner: false do
    it "renders nothing" do
      expect(page).not_to have_css(".govuk-notification-banner")

      expect(page).not_to have_css("#govuk-notification-banner-title", text: "Important")
      expect(page).not_to have_css(".govuk-notification-banner__heading", text: "CSV sandbox is for review and testing purposes only")
      expect(page).not_to have_css(".govuk-notification-banner__content .govuk-body", text: "You must not use real trainee data that contains personally identifiable information.")
      expect(page).not_to have_css(".govuk-notification-banner__content .govuk-body", text: "Send your feedback or questions to registertraineeteachers@education.gov.uk.")
    end
  end

  context "show_csv_sandbox_banner is true", feature_show_csv_sandbox_banner: true do
    it "renders notifications banner" do
      expect(page).to have_css(".govuk-notification-banner")

      expect(page).to have_css("#govuk-notification-banner-title", text: "Important")
      expect(page).to have_css(".govuk-notification-banner__heading", text: "CSV sandbox is for review and testing purposes only")
      expect(page).to have_css(".govuk-notification-banner__content .govuk-body", text: "You must not use real trainee data that contains personally identifiable information.")
      expect(page).to have_css(".govuk-notification-banner__content .govuk-body", text: "Send your feedback or questions to registertraineeteachers@education.gov.uk.")
    end
  end
end
