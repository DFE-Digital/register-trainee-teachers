# frozen_string_literal: true

require "rails_helper"

# New sign-offs go through the Drafts sign-off journey. These scenarios finish a
# submission left awaiting approval by the old two-person flow.
feature "Funding management — finishing a submission awaiting approval",
        feature_funding_management: true, feature_funding_management_edit: true do
  let(:maker) { create(:user, :system_admin) }
  let(:checker) { create(:user, :system_admin) }
  let(:future_cycle) { AcademicCycle.next || create(:academic_cycle, next_cycle: true) }

  before { future_cycle }

  def visit_year
    visit "/system-admin/funding-management/requirements?academic_year=#{future_cycle.start_year}"
  end

  def submit_awaiting_request(by: maker)
    future_cycle.funding_publication_requests.create!(state: :awaiting_approval, submitted_by: by, submitted_at: Time.zone.now)
  end

  scenario "a different colleague reviews then approves, marking it ready for release" do
    submit_awaiting_request(by: maker)
    given_i_am_authenticated(user: checker)
    visit_year

    click_on "Review draft funding"
    expect(page).to have_text("Review #{future_cycle.label} funding before release")
    expect(page).to have_text("Submitted for approval by #{maker.name}")
    expect(page).to have_button("Approve funding")

    click_on "Approve funding"

    expect(page).to have_text("ready for release")
    expect(page).to have_css(".govuk-tag", text: "Ready for release")
    expect(future_cycle.reload.published).to be(true)
    request = future_cycle.funding_publication_requests.latest_first.first
    expect(request).to have_attributes(state: "approved", reviewed_by_id: checker.id)
  end

  scenario "a different colleague rejects with a reason from the review page" do
    submit_awaiting_request(by: maker)
    given_i_am_authenticated(user: checker)
    visit_year
    click_on "Review draft funding"

    fill_in "Reason for rejection (optional)", with: "Bursary amount looks wrong"
    click_on "Reject and return to draft"

    expect(page).to have_text("returned to draft")
    expect(page).to have_css(".govuk-tag", text: "Draft")
    expect(future_cycle.reload.published).to be(false)
    request = future_cycle.funding_publication_requests.latest_first.first
    expect(request).to have_attributes(state: "rejected", decision_notes: "Bursary amount looks wrong", reviewed_by_id: checker.id)
  end

  scenario "the same user can review and approve their own submission (four-eyes relaxed for now)" do
    submit_awaiting_request(by: maker)
    given_i_am_authenticated(user: maker)
    visit_year
    click_on "Review draft funding"

    expect(page).to have_button("Approve funding")
    click_on "Approve funding"

    expect(page).to have_text("ready for release")
    expect(page).to have_css(".govuk-tag", text: "Ready for release")
    expect(future_cycle.reload.published).to be(true)
  end

  scenario "a submission can be withdrawn from the review page" do
    submit_awaiting_request(by: maker)
    given_i_am_authenticated(user: maker)
    visit_year
    click_on "Review draft funding"

    click_on "Withdraw submission"

    expect(page).to have_text("withdrawn")
    expect(page).to have_css(".govuk-tag", text: "Draft")
    expect(future_cycle.funding_publication_requests.latest_first.first.state).to eq("withdrawn")
  end
end
