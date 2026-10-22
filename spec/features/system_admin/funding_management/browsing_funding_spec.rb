# frozen_string_literal: true

require "rails_helper"

feature "Funding management (read-only)", feature_funding_management: true do
  let(:user) { create(:user, :system_admin) }
  let(:academic_cycle) { AcademicCycle.current || create(:academic_cycle, :current) }
  let(:chemistry) { create(:allocation_subject, name: "Chemistry") }

  before do
    given_i_am_authenticated(user:)
    create(:funding_method, training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad], funding_type: :bursary, amount: 29_000, academic_cycle:).tap { |m| m.allocation_subjects << chemistry }
  end

  scenario "filters the entries by funding type, training route and degree relevance" do
    physics = create(:allocation_subject, name: "Physics")
    create(:funding_method, training_route: TRAINING_ROUTE_ENUMS[:school_direct_salaried], funding_type: :grant, amount: 26_000, academic_cycle:).tap { |m| m.allocation_subjects << physics }
    create(:funding_method, training_route: TRAINING_ROUTE_ENUMS[:provider_led_undergrad], funding_type: :bursary, amount: 18_000, degree_relevance: :relevant, academic_cycle:).tap { |m| m.allocation_subjects << physics }

    visit "/system-admin/funding-management/requirements"
    # the three filters are offered
    expect(page).to have_select("Funding type")
    expect(page).to have_select("Training route")
    expect(page).to have_select("Degree relevance")
    # everything shows by default
    expect(page).to have_content("£29,000")
    expect(page).to have_content("£26,000")
    expect(page).to have_content("£18,000")

    visit "/system-admin/funding-management/requirements?funding_type=grant"
    expect(page).to have_content("£26,000")
    expect(page).not_to have_content("£29,000")

    visit "/system-admin/funding-management/requirements?training_route=#{TRAINING_ROUTE_ENUMS[:provider_led_undergrad]}"
    expect(page).to have_content("£18,000")
    expect(page).not_to have_content("£26,000")

    visit "/system-admin/funding-management/requirements?degree_relevance=relevant"
    expect(page).to have_content("£18,000")
    expect(page).not_to have_content("£29,000")
  end

  scenario "filters by subject and school, and applies filters via the button (no JS)" do
    physics = create(:allocation_subject, name: "Physics")
    create(:funding_method, training_route: TRAINING_ROUTE_ENUMS[:school_direct_salaried], funding_type: :grant,
                            amount: 26_000, school_disadvantage: :disadvantaged, academic_cycle:).tap { |m| m.allocation_subjects << physics }

    visit "/system-admin/funding-management/requirements"
    expect(page).to have_select("Subject")
    expect(page).to have_select("School")
    expect(page).to have_button("Apply filters")

    # Subject filter (Chemistry is on the £29,000 record from the outer before block)
    visit "/system-admin/funding-management/requirements?subject_id=#{physics.id}"
    expect(page).to have_content("£26,000")
    expect(page).not_to have_content("£29,000")

    # School filter
    visit "/system-admin/funding-management/requirements?school_disadvantage=disadvantaged"
    expect(page).to have_content("£26,000")
    expect(page).not_to have_content("£29,000")

    # Using the form's Apply button (works without JavaScript)
    visit "/system-admin/funding-management/requirements"
    select "Grant", from: "Funding type"
    click_on "Apply filters"
    expect(page).to have_content("£26,000")
    expect(page).not_to have_content("£29,000")
  end

  scenario "the link appears in the admin nav and reaches the funding entries list" do
    visit "/system-admin/users"
    expect(page).to have_link("Funding", exact: true, href: "/system-admin/funding-management")
    click_link "Funding", exact: true, href: "/system-admin/funding-management"

    # The admin nav lands on the funding management hub; the requirements module
    # lists the entries.
    expect(page).to have_css("h1", text: "Funding management")
    click_on "Funding requirements"

    expect(page).to have_content("ITT Funding requirements")
    expect(page).to have_content(/IFR\d{2}\d{3}/) # entry id
    expect(page).to have_content("Postgraduate bursary") # funding method derived from route
    expect(page).to have_content("Provider led postgraduate")
    expect(page).to have_content("Chemistry")
    expect(page).to have_content("£29,000")
  end

  scenario "clicking a route in the entries list opens its detail" do
    visit "/system-admin/funding-management/requirements"
    click_on "Provider led postgraduate"

    expect(page).to have_content("Funding bands for this route")
    expect(page).to have_content("£29,000")
    expect(page).to have_content("Chemistry")
  end

  scenario "clicking an entry ID opens the entry detail" do
    visit "/system-admin/funding-management/requirements"
    entry_id = find("td", text: /IFR\d{2}\d{3}/).text
    click_on entry_id

    expect(page).to have_content("Funding entry")
    expect(page).to have_content(entry_id)
    expect(page).to have_content("Postgraduate bursary")
    expect(page).to have_content("Provider led postgraduate")
    expect(page).to have_content("£29,000")
    expect(page).to have_content("Chemistry")
  end

  scenario "a route detail shows the bands and eligible subjects" do
    visit "/system-admin/funding-management/#{TRAINING_ROUTE_ENUMS[:provider_led_postgrad]}"

    expect(page).to have_content("Primary and secondary (postgraduate)")
    expect(page).to have_content("Bursary")
    expect(page).to have_content("£29,000")
    expect(page).to have_content("Chemistry")
  end

  scenario "the year selector only lists academic years that have funding" do
    unfunded_cycle = create(:academic_cycle, cycle_year: 2035) # no funding methods

    visit "/system-admin/funding-management/requirements"

    expect(page).to have_content(academic_cycle.label)
    expect(page).not_to have_content(unfunded_cycle.label)
  end

  scenario "subject and route drill into detailed funding requirements" do
    visit "/system-admin/funding-management/subject-records"
    expect(page).to have_link("Chemistry", href: %r{/system-admin/funding-management/subjects/#{chemistry.id}})

    visit "/system-admin/funding-management/subjects/#{chemistry.id}"
    expect(page).to have_content("Chemistry")
    expect(page).to have_content("Funding available for this subject")
    expect(page).to have_content(/IFR\d{2}\d{3}/) # entry id column
    expect(page).to have_css(".govuk-tag", text: "Bursary")
    expect(page).to have_content("£29,000")
    expect(page).to have_content("Postgraduate bursary") # funding method column
    expect(page).to have_link("Provider led postgraduate", href: %r{/system-admin/funding-management/provider_led_postgrad})
  end

  scenario "the old structured view redirects to reports" do
    visit "/system-admin/funding-management/structured-view?academic_year=#{academic_cycle.start_year}"
    expect(page).to have_current_path("/system-admin/funding-management/reports?academic_year=#{academic_cycle.start_year}")
    expect(page).not_to have_link("Structured view")
  end

  scenario "subject records render" do
    visit "/system-admin/funding-management/subject-records"
    expect(page).to have_content("Chemistry")
    expect(page).to have_css(".govuk-tag", text: "Primary and secondary (postgraduate)")
    expect(page).to have_css(".govuk-tag", text: "Bursary")
    expect(page).to have_css(".govuk-tag", text: /Increase|Decrease|New|No change/)
  end

  scenario "reports page offers CSV and JSON downloads and groups funding by type" do
    visit "/system-admin/funding-management/reports"
    expect(page).to have_link("CSV")
    expect(page).to have_link("JSON")
    expect(page).to have_css("caption", text: "Bursary")
    expect(page).to have_content("Chemistry")
    expect(page).to have_content("£29,000")
  end

  scenario "lists every academic year with its status in the filter" do
    visit "/system-admin/funding-management/requirements"
    expect(page).to have_css("#academic_year option", text: "All academic years")
    expect(page).to have_css("#academic_year option", text: /Live/) # the current cycle
  end

  scenario "shows the status tag when scoped to a single year" do
    visit "/system-admin/funding-management/requirements?academic_year=#{academic_cycle.start_year}"
    expect(page).to have_css(".govuk-tag", text: "Live")
    expect(page).to have_content("#{academic_cycle.label} ITT Funding requirements")
  end

  scenario "lists all academic years (including past) in the filter" do
    past_cycle = AcademicCycle.previous || create(:academic_cycle, :previous)
    create(:funding_method, training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad], funding_type: :bursary, amount: 24_000, academic_cycle: past_cycle)

    visit "/system-admin/funding-management/requirements"
    expect(page).to have_css("#academic_year option", text: /#{past_cycle.label} — Past/)
    expect(page).to have_css("#academic_year option", text: "All academic years")
    expect(page).not_to have_button("View")
    expect(page).not_to have_link(/Show past years/)
  end
end

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

feature "Funding management flag off" do
  scenario "is not found when the feature flag is disabled", feature_funding_management: false do
    given_i_am_authenticated(user: create(:user, :system_admin))
    visit "/system-admin/users"
    expect(page).not_to have_link(href: "/system-admin/funding-management")

    visit "/system-admin/funding-management/requirements"
    expect(page).not_to have_css("h1", text: "Funding management")
  end
end
