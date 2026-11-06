# frozen_string_literal: true

require "rails_helper"

feature "Funding management — one route to sign off",
        feature_funding_management: true, feature_funding_management_edit: true do
  scenario "Requirements has no one-click publish or submit; Sign off opens the journey" do
    future_cycle = AcademicCycle.next || create(:academic_cycle, next_cycle: true)
    create(:funding_method, academic_cycle: future_cycle, training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad])
    given_i_am_authenticated(user: create(:user, :system_admin))
    visit "/system-admin/funding-management/requirements?academic_year=#{future_cycle.start_year}"

    expect(page).to have_link("Sign off")
    expect(page).not_to have_button("Mark funding as published")
    expect(page).not_to have_button("Submit funding for approval")

    click_on "Sign off"
    expect(page).to have_current_path("/system-admin/funding-management/drafts/#{future_cycle.start_year}/sign-off")
  end
end
