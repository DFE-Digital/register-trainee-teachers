# frozen_string_literal: true

require "rails_helper"

feature "Relevant degree CAH management", feature_funding_management: true, feature_funding_management_edit: true do
  let(:user) { create(:user, :system_admin) }
  let(:future_cycle) { AcademicCycle.next }
  let!(:biology) { create(:allocation_subject, name: "Biology") }
  let(:hecos) { Funding::CahReference.hecos_options("CAH01-01") }

  before { given_i_am_authenticated(user:) }

  def start_for_future_year
    visit "/system-admin/funding-management/relevant-degrees/add?academic_year=#{future_cycle.start_year}"
    click_on "Continue" # academic year (from the year's page)
    select "Biology", from: "Which ITT subject are these relevant degrees for?"
    click_on "Continue"
  end

  scenario "walks the one-question-per-page wizard and adds a mapping" do
    visit "/system-admin/funding-management/relevant-degrees"
    expect(page).to have_css("h1", text: "Relevant degree CAH management")
    click_on "Add relevant degrees"

    expect(page).to have_css("h1", text: "Which academic year are these relevant degrees for?")
    choose future_cycle.label
    click_on "Continue"

    expect(page).to have_css("h1", text: "Which ITT subject are these relevant degrees for?")
    select "Biology", from: "Which ITT subject are these relevant degrees for?"
    click_on "Continue"

    expect(page).to have_css("h1", text: "Which CAH level 1 category do the degrees belong to?")
    choose "Medicine And Dentistry (CAH01)" # one level 2 category, so its page is skipped
    click_on "Continue"

    expect(page).to have_text("Applicable HECoS codes")
    expect(page).to have_field("Select all")
    first_code, first_label = hecos.first
    check first_label
    click_on "Continue"

    expect(page).to have_text("Check your answers")
    expect(page).to have_text("Biology")
    expect(page).to have_text("CAH01-01")
    expect(page).to have_text("Set by the CAH level 1 category")
    expect(page).not_to have_link("Change CAH level 2 category")

    expect {
      click_on "Add relevant degrees"
    }.to change(RelevantDegreeMapping, :count).by(1)

    expect(page).to have_text("relevant degree record added for Biology")
    mapping = RelevantDegreeMapping.last
    expect(mapping).to have_attributes(allocation_subject: biology, academic_cycle: future_cycle,
                                       cah_level_1_code: "CAH01", cah_level_2_code: "CAH01-01",
                                       hecos_code: first_code)
    expect(mapping.reference).to eq("DRCAH001")
    expect(page).to have_text("DRCAH001")
  end

  scenario "asks for the CAH level 2 category when there is a choice" do
    start_for_future_year
    choose "Physical Sciences (CAH07)"
    click_on "Continue"

    expect(page).to have_css("h1", text: "Which CAH level 2 category in Physical Sciences?")
    click_on "Continue"
    expect(page).to have_css(".govuk-error-summary", text: "Select a CAH level 2 category")

    choose "Chemistry (CAH07-02)"
    click_on "Continue"
    expect(page).to have_text("Applicable HECoS codes for Chemistry")
  end

  scenario "does not preselect an academic year" do
    visit "/system-admin/funding-management/relevant-degrees/add"

    expect(page).to have_unchecked_field(future_cycle.label)
    click_on "Continue"
    expect(page).to have_css(".govuk-error-summary", text: "Select an academic year")
  end

  scenario "shows an error when no CAH level 1 category is chosen" do
    start_for_future_year
    click_on "Continue"

    expect(page).to have_css(".govuk-error-summary", text: "Select a CAH level 1 category")
  end

  scenario "shows an error when no HECoS code is selected" do
    start_for_future_year
    choose "Medicine And Dentistry (CAH01)"
    click_on "Continue"

    click_on "Continue" # HECoS — nothing selected
    expect(page).to have_css(".govuk-error-summary")
    expect(page).to have_text("Select at least one HECoS code")
  end

  scenario "changing the CAH level 1 category from Check your answers asks for the rest again" do
    start_for_future_year
    choose "Medicine And Dentistry (CAH01)"
    click_on "Continue"
    check hecos.first.last
    click_on "Continue"

    click_link "Change CAH level 1 category"
    choose "Physical Sciences (CAH07)"
    click_on "Save and continue"

    expect(page).to have_css("h1", text: "Which CAH level 2 category in Physical Sciences?")
    choose "Chemistry (CAH07-02)"
    click_on "Continue"
    expect(page).to have_text("Applicable HECoS codes for Chemistry")
    expect(page).not_to have_checked_field(hecos.first.last)
  end

  scenario "the old two-question addresses redirect to the new first questions" do
    visit "/system-admin/funding-management/relevant-degrees/add/year_subject"
    expect(page).to have_current_path("/system-admin/funding-management/relevant-degrees/add/academic_year")

    visit "/system-admin/funding-management/relevant-degrees/add/cah_levels"
    expect(page).to have_current_path("/system-admin/funding-management/relevant-degrees/add/cah_level_1")
  end

  scenario "removes a mapping from a future (draft) year" do
    create(:relevant_degree_mapping, academic_cycle: future_cycle, allocation_subject: biology)

    visit "/system-admin/funding-management/relevant-degrees?academic_year=#{future_cycle.start_year}"
    expect(page).to have_text("Biology")

    expect {
      click_on "Remove"
    }.to change(RelevantDegreeMapping, :count).by(-1)
    expect(page).to have_text("Relevant degrees removed for Biology")
  end

  scenario "appears in the funding sub-navigation" do
    visit "/system-admin/funding-management/relevant-degrees"
    within("nav[aria-label='Funding']") do
      expect(page).to have_link("Funding requirements")
      expect(page).to have_css("a[aria-current='page']", text: "Relevant degree CAH management")
    end
  end
end
