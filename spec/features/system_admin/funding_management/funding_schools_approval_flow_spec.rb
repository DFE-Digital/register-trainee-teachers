# frozen_string_literal: true

require "rails_helper"

feature "Funding schools management — approval flow",
        feature_funding_management: true, feature_funding_management_approval: true, feature_funding_management_edit: true do
  let(:user) { create(:user, :system_admin) }
  let(:future_cycle) { AcademicCycle.next }
  let!(:school) { create(:school, urn: "777777", name: "Approval Primary") }

  before { given_i_am_authenticated(user:) }

  scenario "the school list is locked once the year is submitted for approval" do
    create(:funding_school_designation, school: school, academic_cycle: future_cycle)
    future_cycle.funding_publication_requests.create!(state: :awaiting_approval, submitted_by: user, submitted_at: Time.zone.now)

    visit "/system-admin/funding-management/schools?academic_year=#{future_cycle.start_year}"

    expect(page).to have_text("Approval Primary")
    expect(page).not_to have_link("Add a school")
    expect(page).not_to have_button("Remove")
    expect(page).to have_text("submitted for approval")
  end

  scenario "the school list appears on the funding approval review page" do
    create(:funding_school_designation, school: school, academic_cycle: future_cycle, designation: :special)
    future_cycle.funding_publication_requests.create!(state: :awaiting_approval, submitted_by: user, submitted_at: Time.zone.now)

    visit "/system-admin/funding-management/publish/review?academic_year=#{future_cycle.start_year}"

    expect(page).to have_text("Funding schools list")
    expect(page).to have_text("Approval Primary")
    expect(page).to have_text("777777")
    expect(page).to have_text("Special school")
  end
end
