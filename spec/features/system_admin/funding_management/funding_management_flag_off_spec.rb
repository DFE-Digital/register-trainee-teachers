# frozen_string_literal: true

require "rails_helper"

feature "Funding management flag off" do
  scenario "is not found when the feature flag is disabled", feature_funding_management: false do
    given_i_am_authenticated(user: create(:user, :system_admin))
    visit "/system-admin/users"
    expect(page).to have_css("h1")
    expect(page).not_to have_link(href: "/system-admin/funding-management")

    visit "/system-admin/funding-management/requirements"
    expect(page).to have_css("h1")
    expect(page).not_to have_css("h1", text: "Funding management")
  end
end
