# frozen_string_literal: true

require "rails_helper"

feature "Funding schools management", feature_funding_management: true, feature_funding_management_edit: true do
  let(:user) { create(:user, :system_admin) }
  let(:future_cycle) { AcademicCycle.next }

  before { given_i_am_authenticated(user:) }

  def when_i_answer_year_and_designation(designation: "Disadvantaged school")
    visit "/system-admin/funding-management/schools/new"
    choose future_cycle.label
    click_on "Continue"
    choose designation
    click_on "Continue"
  end

  scenario "adds a school one question at a time, then checks its details" do
    school = create(:school, urn: "123456", name: "Greendale Primary", town: "Greendale", postcode: "GD1 1AA")

    visit "/system-admin/funding-management/schools"
    click_on "Add a school"

    expect(page).to have_css("h1", text: "Which academic year does this school apply to?")
    choose future_cycle.label
    click_on "Continue"

    expect(page).to have_css("h1", text: "How is this school designated?")
    choose "Disadvantaged school"
    click_on "Continue"

    expect(page).to have_css("h1", text: "Which school is it?")
    fill_in "Which school is it?", with: "123456" # without JavaScript the search takes a URN
    click_on "Continue"

    # The check page shows the school's details before saving
    expect(page).to have_css("h1", text: "Check this is the right school")
    expect(page).to have_text("Greendale Primary")
    expect(page).to have_text("123456")
    expect(page).to have_text("Greendale")
    expect(page).to have_text("GD1 1AA")
    expect(page).to have_css(".govuk-tag", text: "Open")
    expect(page).to have_text("Disadvantaged school")

    expect {
      click_on "Confirm and add"
    }.to change(FundingSchoolDesignation, :count).by(1)

    expect(page).to have_text("Greendale Primary added to the funding schools list")
    designation = FundingSchoolDesignation.last
    expect(designation.school).to eq(school)
    expect(designation.academic_cycle).to eq(future_cycle)
    expect(designation).to be_disadvantaged
  end

  scenario "does not preselect an academic year" do
    visit "/system-admin/funding-management/schools/new"

    expect(page).to have_unchecked_field(future_cycle.label)
    click_on "Continue"
    expect(page).to have_css(".govuk-error-summary", text: "Select an academic year")
  end

  scenario "asks for a school when none is entered" do
    when_i_answer_year_and_designation
    click_on "Continue"

    expect(page).to have_css(".govuk-error-summary", text: "Enter a school URN or search for a school")
  end

  scenario "shows a validation error for a closed school" do
    create(:school, :closed, urn: "222222", name: "Old School")

    when_i_answer_year_and_designation(designation: "Special school")
    fill_in "Which school is it?", with: "222222"
    click_on "Continue"

    expect(page).to have_css(".govuk-error-summary")
    expect(page).to have_text("Old School (URN 222222) is closed and cannot be added.")
  end

  scenario "shows a validation error for a non-existent school" do
    when_i_answer_year_and_designation
    fill_in "Which school is it?", with: "654321"
    click_on "Continue"

    expect(page).to have_css(".govuk-error-summary")
    expect(page).to have_text("No school with URN 654321 was found")
  end

  scenario "shows a validation error for a school already on the list" do
    school = create(:school, urn: "343434", name: "Listed Academy")
    create(:funding_school_designation, school: school, academic_cycle: future_cycle)

    when_i_answer_year_and_designation
    fill_in "Which school is it?", with: "343434"
    click_on "Continue"

    expect(page).to have_css(".govuk-error-summary", text: "Listed Academy is already on the list for #{future_cycle.label}.")
  end

  scenario "Change links on the check page return to it" do
    create(:school, urn: "123456", name: "Greendale Primary")
    when_i_answer_year_and_designation
    fill_in "Which school is it?", with: "123456"
    click_on "Continue"

    click_link "Change designation"
    choose "Special school"
    click_on "Save and continue"

    expect(page).to have_css("h1", text: "Check this is the right school")
    expect(page).to have_text("Special school")
  end

  scenario "removes a school from a future (draft) year" do
    school = create(:school, urn: "333333", name: "Removable School")
    create(:funding_school_designation, school:, academic_cycle: future_cycle)

    visit "/system-admin/funding-management/schools?academic_year=#{future_cycle.start_year}"
    expect(page).to have_content("Removable School")

    expect {
      click_on "Remove"
    }.to change(FundingSchoolDesignation, :count).by(-1)

    expect(page).to have_content("Removable School removed from the funding schools list")
  end

  scenario "bulk uploads a CSV, adding valid URNs and reporting the rest" do
    create(:school, urn: "444444", name: "Alpha School")
    create(:school, :closed, urn: "555555", name: "Closed School")
    # 666666 does not exist

    csv = Tempfile.new(["urns", ".csv"])
    csv.write("urn\n444444\n555555\n666666\n")
    csv.rewind

    visit "/system-admin/funding-management/schools/bulk-upload"
    select future_cycle.label, from: "Which academic year does this apply to?"
    choose "Disadvantaged school"
    attach_file "CSV file of URNs", csv.path
    click_on "Upload and check"

    expect(page).to have_content("Bulk upload results")
    expect(page).to have_content("Alpha School")            # added
    expect(page).to have_content("Closed School")           # skipped, closed
    expect(page).to have_content("No school with URN 666666") # skipped, missing

    expect(FundingSchoolDesignation.count).to eq(1)
    expect(FundingSchoolDesignation.last.school.urn).to eq("444444")
  ensure
    csv&.close!
  end
end

feature "Funding schools management — approval flow",
        feature_funding_management: true, feature_funding_management_edit: true,
        feature_funding_management_approval: true do
  let(:user) { create(:user, :system_admin) }
  let(:future_cycle) { AcademicCycle.next }
  let!(:school) { create(:school, urn: "777777", name: "Approval Primary") }

  before { given_i_am_authenticated(user:) }

  scenario "the school list is locked once the year is submitted for approval" do
    create(:funding_school_designation, school:, academic_cycle: future_cycle)
    future_cycle.funding_publication_requests.create!(state: :awaiting_approval, submitted_by: user, submitted_at: Time.zone.now)

    visit "/system-admin/funding-management/schools?academic_year=#{future_cycle.start_year}"

    expect(page).to have_content("Approval Primary")
    expect(page).to have_no_link("Add a school")
    expect(page).to have_no_button("Remove")
    expect(page).to have_content("submitted for approval")
  end

  scenario "the school list appears on the funding approval review page" do
    create(:funding_school_designation, school:, academic_cycle: future_cycle, designation: :special)
    future_cycle.funding_publication_requests.create!(state: :awaiting_approval, submitted_by: user, submitted_at: Time.zone.now)

    visit "/system-admin/funding-management/publish/review?academic_year=#{future_cycle.start_year}"

    expect(page).to have_content("Funding schools list")
    expect(page).to have_content("Approval Primary")
    expect(page).to have_content("777777")
    expect(page).to have_content("Special school")
  end
end
