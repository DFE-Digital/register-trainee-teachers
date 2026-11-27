# frozen_string_literal: true

require "rails_helper"

feature "Viewing relevant degrees" do
  context "when I am authenticated as a system admin" do
    before do
      given_i_am_authenticated_as_system_admin
      when_i_visit_the_root_page
      and_i_click_on_support_for_register
      and_i_click_on_the_funding_link
      then_i_am_on_the_funding_uploads_page
    end

    scenario "navigate to the relevant degrees page" do
      given_there_are_relevant_degrees
      when_i_click_on_the_relevant_degrees_link
      then_i_am_on_the_relevant_degrees_page
      and_i_see_the_relevant_degrees
    end

    scenario "there are no relevant degrees" do
      when_i_click_on_the_relevant_degrees_link
      then_i_am_on_the_relevant_degrees_page
      and_i_see_there_are_no_relevant_degrees
    end
  end

  context "when I am authenticated as a regular user (not a system admin)" do
    before do
      given_i_am_authenticated
    end

    scenario "the relevant degrees page is inaccessible" do
      expect { when_i_visit_the_relevant_degrees_page }.to raise_error(ActionController::RoutingError)
    end
  end

private

  def given_there_are_relevant_degrees
    chemistry = create(:allocation_subject, name: "Chemistry")
    physics = create(:allocation_subject, name: "Physics")
    create(:relevant_degree_subject, academic_cycle: AcademicCycle.current, allocation_subject: physics, hecos_code: "100425")
    create(:relevant_degree_subject, academic_cycle: AcademicCycle.next, allocation_subject: chemistry, hecos_code: "100417")
  end

  def when_i_visit_the_root_page
    visit "/"
  end

  def when_i_visit_the_relevant_degrees_page
    visit "/system-admin/funding-management/relevant-degrees"
  end

  def and_i_click_on_support_for_register
    click_on("Support")
  end

  def and_i_click_on_the_funding_link
    click_on("Funding")
  end

  def then_i_am_on_the_funding_uploads_page
    expect(page).to have_current_path("/system-admin/funding-uploads")
  end

  def when_i_click_on_the_relevant_degrees_link
    click_on("Relevant degrees")
  end

  def then_i_am_on_the_relevant_degrees_page
    expect(page).to have_current_path("/system-admin/funding-management/relevant-degrees")
    expect(page).to have_css("h1", text: "Relevant degrees")
    expect(page).to have_css("a[aria-current='page']", text: "Funding", exact_text: true)
  end

  def and_i_see_the_relevant_degrees
    rows = page.all(".govuk-table__body .govuk-table__row").map { |row| row.all(".govuk-table__cell").map(&:text) }

    expect(rows).to eq(
      [
        [AcademicCycle.next.label, "Chemistry", "Chemistry", "100417"],
        [AcademicCycle.current.label, "Physics", "Physics", "100425"],
      ],
    )
  end

  def and_i_see_there_are_no_relevant_degrees
    expect(page).to have_text("There are no relevant degrees.")
    expect(page).not_to have_css(".govuk-table")
  end
end
