# frozen_string_literal: true

require "rails_helper"

feature "List funding school designations" do
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

      given_i_am_authenticated(user:)
    end

    scenario "defaults to the next academic year when the current year has no schools" do
      when_i_visit_the_funding_school_designations_index_page
      then_i_see_the_2027_schools
      and_i_do_not_see_schools_from_other_years
    end

    scenario "filters by academic year" do
      create(:funding_school_designation, school: other_year_school, academic_cycle: academic_cycle_2026)

      when_i_visit_the_funding_school_designations_index_page
      and_i_filter_by_academic_year("2026 to 2027")
      then_i_see_the_2026_school
      and_i_do_not_see_the_2027_schools
    end

    scenario "shows schools for all academic years" do
      create(:funding_school_designation, school: other_year_school, academic_cycle: academic_cycle_2026)

      when_i_visit_the_funding_school_designations_index_page
      and_i_filter_by_academic_year("All academic years")
      then_i_see_the_2027_schools
      and_i_see_the_2026_school
      and_i_see_the_academic_year_column
    end

    scenario "navigates from the funding tab" do
      when_i_visit_the_users_page
      and_i_click_funding
      and_i_click_disadvantaged_and_special_schools
      then_i_am_on_the_funding_school_designations_index_page
    end
  end

  context "as a non-system admin" do
    let(:user) { create(:user) }

    before do
      given_i_am_authenticated(user:)
    end

    scenario "cannot access the funding school designations index" do
      expect { when_i_visit_the_funding_school_designations_index_page }.to raise_error(ActionController::RoutingError)
    end
  end

  def when_i_visit_the_funding_school_designations_index_page
    funding_school_designations_index_page.load
  end

  def when_i_visit_the_users_page
    visit users_path
  end

  def and_i_click_funding
    click_link "Funding", exact: true
  end

  def and_i_click_disadvantaged_and_special_schools
    click_on "Disadvantaged and special schools"
  end

  def and_i_filter_by_academic_year(label)
    select label, from: "Academic year"
    click_on "Apply filter"
  end

  def then_i_am_on_the_funding_school_designations_index_page
    expect(page).to have_current_path(funding_management_schools_path)
  end

  def then_i_see_the_2027_schools
    expect(page).to have_css("h1", text: "Disadvantaged and special schools")
    expect(page).to have_text("Greendale Primary")
    expect(page).to have_text("111111")
    expect(page).to have_text("Greendale")
    expect(page).to have_text("Disadvantaged school")
    expect(page).to have_text("Special Academy")
    expect(page).to have_text("222222")
    expect(page).to have_text("Special school")
  end

  def and_i_do_not_see_the_2027_schools
    expect(page).not_to have_text("Greendale Primary")
    expect(page).not_to have_text("Special Academy")
  end

  def then_i_see_the_2026_school
    expect(page).to have_text("Wrong Year School")
    expect(page).to have_text("333333")
  end

  def and_i_see_the_2026_school
    then_i_see_the_2026_school
  end

  def and_i_do_not_see_schools_from_other_years
    expect(page).not_to have_text("Wrong Year School")
    expect(page).not_to have_text("333333")
  end

  def and_i_see_the_academic_year_column
    expect(page).to have_css("th", text: "Academic year")
    expect(page).to have_text("2027 to 2028")
    expect(page).to have_text("2026 to 2027")
  end
end
