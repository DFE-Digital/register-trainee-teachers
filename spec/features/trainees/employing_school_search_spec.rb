# frozen_string_literal: true

require "rails_helper"

RSpec.feature "EmployingSchoolSearch", type: :feature do
  before do
    given_i_am_authenticated
    given_a_school_direct_salaried_trainee_exists
    and_a_number_of_schools_exist
    and_i_visit_the_trainee_edit_employing_school_page
  end

  scenario "choosing a employing school", js: true do
    and_i_fill_in_my_employing_school
    and_i_click_the_first_item_in_the_list
    and_i_continue
    then_i_am_redirected_to_the_confirm_lead_school_page
  end

  scenario "choosing a employing school without javascript" do
    and_i_fill_in_my_employing_school_without_js
    and_i_continue
    then_i_am_redirected_to_the_employing_schools_page_filtered_by_my_query
  end

  scenario "when a employing school is not selected", js: true do
    and_i_fill_in_my_employing_school
    and_i_continue
    then_i_am_redirected_to_the_employing_schools_page_filtered_by_my_query
  end

private

  def given_a_school_direct_salaried_trainee_exists
    given_a_trainee_exists(training_route: :school_direct_salaried)
  end

  def and_i_fill_in_my_employing_school
    edit_employing_school_page.employing_school.fill_in with: my_employing_school_name
  end

  def and_i_fill_in_my_employing_school_without_js
    edit_employing_school_page.no_js_employing_school.fill_in with: my_employing_school_name
  end

  def and_i_click_the_first_item_in_the_list
    click(edit_employing_school_page.autocomplete_list_item)
  end

  def and_i_continue
    click(edit_employing_school_page.submit)
  end

  def and_a_number_of_schools_exist
    @employing_schools = create_list(:school, 5)
  end

  def and_i_visit_the_trainee_edit_employing_school_page
    edit_employing_school_page.load(trainee_id: trainee.slug)
  end

  def my_employing_school_name
    my_employing_school.name.split(" ").first
  end

  def my_employing_school
    @my_employing_school ||= @employing_schools.sample
  end

  def then_i_am_redirected_to_the_confirm_lead_school_page
    expect(confirm_schools_page).to be_displayed(id: trainee.slug)
  end

  def then_i_am_redirected_to_the_employing_schools_page_filtered_by_my_query
    expect(employing_schools_search_page).to be_displayed(trainee_id: trainee.slug, query: my_employing_school_name)
  end
end
