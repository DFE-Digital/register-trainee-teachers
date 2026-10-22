# frozen_string_literal: true

require "rails_helper"

feature "Funding management — publishing a draft year", feature_funding_management: true, feature_funding_management_edit: true do
  scenario "an admin publishes a future draft year" do
    given_i_am_authenticated(user: create(:user, :system_admin))
    future_cycle = AcademicCycle.next || create(:academic_cycle, next_cycle: true)
    create(:funding_method, training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad], funding_type: :bursary, amount: 30_000, academic_cycle: future_cycle)

    visit "/system-admin/funding-management/requirements?academic_year=#{future_cycle.start_year}"
    expect(page).to have_css(".govuk-tag", text: "Draft")

    expect(page).not_to have_button("Mark funding as published")
    click_on "Sign off" # the one route to sign off: the Drafts sign-off journey
    click_on "Sign off"
    click_on "Approve"

    expect(page).to have_css(".govuk-panel__title", text: "approved")
    expect(future_cycle.reload.published).to be(true)

    visit "/system-admin/funding-management/requirements?academic_year=#{future_cycle.start_year}"
    expect(page).to have_css(".govuk-tag", text: "Ready for release")
    expect(page).not_to have_link("Add funding")
    click_on "Reopen for editing"

    expect(page).to have_text("reopened for editing")
    expect(future_cycle.reload.published).to be(false)
  end
end
