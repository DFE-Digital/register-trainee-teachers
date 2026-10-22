# frozen_string_literal: true

require "rails_helper"

feature "Funding management — signing off draft funding requirements", feature_funding_management: true, feature_funding_management_edit: true do
  let(:user) { create(:user, :system_admin, first_name: "Agatha", last_name: "Baker") }
  let(:next_cycle) { AcademicCycle.next }
  let(:short_year) { format("%02d/%02d", next_cycle.start_year % 100, (next_cycle.start_year + 1) % 100) }
  let(:go_live) { next_cycle.start_date.to_fs(:govuk) }

  before do
    given_i_am_authenticated(user:)
    chemistry = create(:allocation_subject, name: "Chemistry")
    create_list(:funding_method, 2, academic_cycle: next_cycle, training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad])
      .each { |method| method.allocation_subjects << chemistry }
  end

  def when_i_open_sign_off_from_drafts
    visit "/system-admin/funding-management/drafts"
    click_on "Sign off"
  end

  scenario "one person reviews, approves and sees the go-live date" do
    when_i_open_sign_off_from_drafts

    expect(page).to have_css("h1", text: "Sign off #{short_year} funding requirements")
    expect(page).to have_text("Goes live on#{go_live}")
    expect(page).to have_css("tbody tr", count: 2)
    click_on "Sign off"

    expect(page).to have_css("h1", text: "Approve #{short_year} funding requirements")
    expect(page).to have_text("By approving, you confirm that you have reviewed and approve the documented #{short_year} funding requirements")
    expect(page).to have_css(".govuk-warning-text", text: "After these funding requirements go live on #{go_live}, any amendment will need a Register developer to make it.")
    click_on "Approve"

    expect(page).to have_css(".govuk-panel__title", text: "#{short_year} funding requirements approved")
    expect(page).to have_css(".govuk-panel__body", text: "They will go live on #{go_live}")
    expect(page).to have_css(".govuk-tag", text: "Ready for release")
    expect(page).to have_text("Approved byAgatha Baker")

    expect(next_cycle.reload.published).to be(true)
    expect(next_cycle.latest_approval).to have_attributes(submitted_by: user, reviewed_by: user)
  end

  scenario "Cancel on the review page changes nothing" do
    when_i_open_sign_off_from_drafts
    click_on "Cancel"

    expect(page).to have_current_path("/system-admin/funding-management/drafts")
    expect(next_cycle.reload.published).to be(false)
  end

  scenario "Cancel on the approve page changes nothing" do
    when_i_open_sign_off_from_drafts
    click_on "Sign off"
    click_on "Cancel"

    expect(page).to have_current_path("/system-admin/funding-management/drafts")
    expect(next_cycle.reload.published).to be(false)
    expect(next_cycle.funding_publication_requests).to be_empty
  end

  scenario "a Ready for release year can be reopened for editing" do
    when_i_open_sign_off_from_drafts
    click_on "Sign off"
    click_on "Approve"

    visit "/system-admin/funding-management/drafts"
    click_on "Reopen"

    expect(page).to have_text("#{short_year} funding requirements reopened for editing")
    within("tr", text: "#{short_year} requirements") do
      expect(page).to have_css(".govuk-tag", text: "Draft")
      expect(page).to have_link("Sign off")
    end
    expect(next_cycle.reload.published).to be(false)
    expect(next_cycle.funding_publication_requests.pluck(:state)).to eq(%w[withdrawn])
  end

  scenario "an approved year goes live on its start date and appears on Requirements" do
    next_cycle.update!(published: true)

    Timecop.travel(next_cycle.start_date + 1.day) do
      given_i_am_authenticated(user:) # the earlier session has timed out
      visit "/system-admin/funding-management/requirements"

      expect(page).to have_select("Academic year", with_options: ["#{next_cycle.label} — Live"])

      visit "/system-admin/funding-management/drafts"
      expect(page).to have_css("h1", text: "Draft funding requirements")
      expect(page).not_to have_link("#{short_year} requirements")
    end
  end

  scenario "years that cannot be signed off go back to Drafts" do
    next_cycle.update!(published: true)

    visit "/system-admin/funding-management/drafts/#{next_cycle.start_year}/sign-off"

    expect(page).to have_current_path("/system-admin/funding-management/drafts")
    expect(page).to have_text("#{short_year} funding requirements cannot be signed off.")
  end
end
