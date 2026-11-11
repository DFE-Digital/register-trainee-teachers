# frozen_string_literal: true

require "rails_helper"

feature "Funding management — draft funding requirements", feature_funding_management: true, feature_funding_management_edit: true do
  let(:user) { create(:user, :system_admin) }
  # rails_helper seeds previous/current/next cycles for feature specs.
  let(:current_cycle) { AcademicCycle.current }
  let(:next_cycle) { AcademicCycle.next }

  def short_year(cycle) = format("%02d/%02d", cycle.start_year % 100, (cycle.start_year + 1) % 100)

  before do
    given_i_am_authenticated(user:)
    create(:funding_method, academic_cycle: current_cycle, training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad])
    chemistry = create(:allocation_subject, name: "Chemistry")
    create_list(:funding_method, 2, academic_cycle: next_cycle, training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad])
      .each { |method| method.allocation_subjects << chemistry }
  end

  scenario "the Drafts link lists future years that are not published yet" do
    visit "/system-admin/funding-management/requirements"
    within("nav[aria-label=\"Funding management\"]") { click_on "Drafts" }

    expect(page).to have_css("h1", text: "Draft funding requirements")
    expect(page).to have_link("#{short_year(next_cycle)} requirements", href: "/system-admin/funding-management/requirements?academic_year=#{next_cycle.start_year}")
    expect(page).not_to have_link("#{short_year(current_cycle)} requirements")

    within("tr", text: "#{short_year(next_cycle)} requirements") do
      expect(page).to have_css(".govuk-tag", text: "Draft")
      expect(page).to have_text("2")
      expect(page).to have_link("Sign off")
      expect(page).to have_link("Delete")
      expect(page).not_to have_link(/Roll over/)
    end
  end

  scenario "only drafts with at least one funding record are listed" do
    empty_draft = AcademicCycle.for_year(next_cycle.start_year + 1) || create(:academic_cycle, cycle_year: next_cycle.start_year + 1)

    visit "/system-admin/funding-management/drafts"

    expect(page).to have_link("#{short_year(next_cycle)} requirements")
    expect(page).not_to have_link("#{short_year(empty_draft)} requirements")
  end

  scenario "deleting a draft asks for confirmation first" do
    visit "/system-admin/funding-management/drafts"
    click_on "Delete"

    expect(page).to have_css("h1", text: "Are you sure you want to delete #{short_year(next_cycle)} requirements?")
    expect(page).to have_text("This will delete all 2 funding records")

    click_on "Delete draft funding"

    expect(page).to have_current_path("/system-admin/funding-management/drafts")
    expect(page).to have_text("Deleted #{next_cycle.label} draft funding (2 funding records)")
    expect(next_cycle.funding_methods.count).to eq(0)
    expect(page).to have_text("There are no drafts in progress.")
  end

  scenario "Requirements does not offer draft years" do
    visit "/system-admin/funding-management/requirements"

    expect(page).to have_select("Academic year", with_options: ["#{current_cycle.label} — Live"])
    expect(page).not_to have_select("Academic year", with_options: ["#{next_cycle.label} — Draft"])
  end

  scenario "a draft year opened from Drafts still shows on Requirements" do
    visit "/system-admin/funding-management/drafts"
    click_on "#{short_year(next_cycle)} requirements"

    expect(page).to have_select("Academic year", selected: "#{next_cycle.label} — Draft")
    expect(page).not_to have_select("Academic year", with_options: ["#{current_cycle.label} — Live"])
    expect(page).not_to have_select("Academic year", with_options: ["All academic years"])
    expect(page).to have_text("2 funding entries")
  end

  scenario "an approved year stays on Drafts as Ready for release until it goes live" do
    next_cycle.update!(published: true)

    visit "/system-admin/funding-management/drafts"

    within("tr", text: "#{short_year(next_cycle)} requirements") do
      expect(page).to have_css(".govuk-tag", text: "Ready for release")
      expect(page).to have_button("Reopen")
      expect(page).not_to have_link("Sign off")
      expect(page).not_to have_link("Delete")
    end

    visit "/system-admin/funding-management/requirements"
    expect(page).to have_css("h1", text: "Funding requirements")
    expect(page).not_to have_select("Academic year", with_options: ["#{next_cycle.label} — Ready for release"])
  end
end
