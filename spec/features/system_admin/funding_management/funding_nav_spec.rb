# frozen_string_literal: true

require "rails_helper"

feature "Funding management landing", feature_funding_management: true, feature_funding_uploads: true do
  let(:user) { create(:user, :system_admin) }

  before { given_i_am_authenticated(user:) }

  scenario "the landing page links to each funding module" do
    visit "/system-admin/funding-management"

    expect(page).to have_css("h1", text: "Funding management")
    expect(page).to have_link("Funding requirements", href: "/system-admin/funding-management/requirements")
    expect(page).to have_link("Funding upload", href: "/system-admin/funding-uploads")
    expect(page).to have_link("Funding schools management", href: "/system-admin/funding-management/schools")
  end

  scenario "navigates from the landing page into a module and back via the funding sub-nav" do
    visit "/system-admin/funding-management"
    click_on "Funding schools management"

    expect(page).to have_current_path("/system-admin/funding-management/schools")
    expect(page).to have_css("h1", text: "Funding schools management")

    within("nav[aria-label='Funding']") do
      expect(page).to have_link("Funding requirements", href: "/system-admin/funding-management/requirements")
      expect(page).to have_link("Funding upload", href: "/system-admin/funding-uploads")
      # Schools is the current page — marked with aria-current
      expect(page).to have_css("a[aria-current='page']", text: "Funding schools management")
    end

    click_on "Funding requirements"
    expect(page).to have_current_path("/system-admin/funding-management/requirements")
    expect(page).to have_css("h1", text: "Funding requirements")
  end
end
