# frozen_string_literal: true

require "rails_helper"

feature "Funding management — add funding flag off" do
  scenario "the wizard is not reachable when funding_management_edit is disabled",
           feature_funding_management: true, feature_funding_management_edit: false do
    given_i_am_authenticated(user: create(:user, :system_admin))

    visit "/system-admin/funding-management/requirements"
    expect(page).to have_css("h1")
    expect(page).not_to have_link("Add funding")

    visit "/system-admin/funding-management/add"
    expect(page).to have_css("h1")
    expect(page).not_to have_text("Which academic year is this funding for?")
  end
end
