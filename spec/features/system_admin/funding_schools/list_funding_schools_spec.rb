# frozen_string_literal: true

require "rails_helper"

feature "List funding schools" do
  let(:academic_cycle_2027) { AcademicCycle.for_year(2027) || create(:academic_cycle, cycle_year: 2027) }
  let(:academic_cycle_2026) { AcademicCycle.for_year(2026) || create(:academic_cycle, cycle_year: 2026) }

  context "as a system admin" do
    let(:user) { create(:user, :system_admin) }
    let!(:disadvantaged_school) { create(:school, name: "Greendale Primary", urn: "111111", town: "Greendale") }
    let!(:special_school) { create(:school, name: "Special Academy", urn: "222222", town: "Specialtown") }
    let!(:other_year_school) { create(:school, name: "Wrong Year School", urn: "333333") }

    before do
      create(:funding_school_designation, school: disadvantaged_school, academic_cycle: academic_cycle_2027)
      create(:funding_school_designation, :special, school: special_school, academic_cycle: academic_cycle_2027)
      create(:funding_school_designation, school: other_year_school, academic_cycle: academic_cycle_2026)

      given_i_am_authenticated(user:)
    end

    scenario "lists disadvantaged and special schools for 2027 to 2028" do
      when_i_visit_the_funding_schools_index_page
      then_i_see_the_2027_schools
      and_i_do_not_see_schools_from_other_years
    end

    scenario "navigates from the support console tab" do
      when_i_visit_the_users_page
      and_i_click_funding_schools
      then_i_am_on_the_funding_schools_index_page
    end
  end

  context "as a non-system admin" do
    let(:user) { create(:user) }

    before do
      given_i_am_authenticated(user:)
    end

    scenario "cannot access the funding schools index" do
      expect { when_i_visit_the_funding_schools_index_page }.to raise_error(ActionController::RoutingError)
    end
  end

  def when_i_visit_the_funding_schools_index_page
    funding_schools_index_page.load
  end

  def when_i_visit_the_users_page
    visit users_path
  end

  def and_i_click_funding_schools
    click_on "Funding schools"
  end

  def then_i_am_on_the_funding_schools_index_page
    expect(page).to have_current_path(funding_management_schools_path)
  end

  def then_i_see_the_2027_schools
    expect(page).to have_css("h1", text: "Disadvantaged and special schools")
    expect(page).to have_text("Greendale Primary")
    expect(page).to have_text("111111")
    expect(page).to have_text("Greendale")
    expect(page).to have_css(".govuk-tag", text: "Disadvantaged school")
    expect(page).to have_text("Special Academy")
    expect(page).to have_text("222222")
    expect(page).to have_css(".govuk-tag", text: "Special school")
    expect(page).to have_text("2 schools")
  end

  def and_i_do_not_see_schools_from_other_years
    expect(page).not_to have_text("Wrong Year School")
    expect(page).not_to have_text("333333")
  end
end
