# frozen_string_literal: true

require "rails_helper"

RSpec.feature "LeadSchoolSearch", type: :feature do
  before do
    given_i_am_authenticated
    given_a_school_direct_salaried_trainee_exists
    and_a_number_of_lead_schools_exist
    and_i_visit_the_trainee_edit_lead_school_page
  end

  scenario "choosing a lead school", js: true do
    and_i_fill_in_my_lead_school
    and_i_click_the_first_item_in_the_list
    and_i_continue
    then_i_am_redirected_to_the_confirm_training_details_page
  end

  scenario "choosing a lead school without javascript" do
    and_i_fill_in_my_lead_school_without_js
    and_i_continue
    then_i_am_redirected_to_the_lead_schools_page_filtered_by_my_query
  end

  scenario "when a lead school is not selected", js: true do
    and_i_fill_in_my_lead_school
    and_i_continue
    then_i_am_redirected_to_the_lead_schools_page_filtered_by_my_query
  end

private

  def given_a_school_direct_salaried_trainee_exists
    given_a_trainee_exists(:school_direct_salaried)
  end

  def and_i_fill_in_my_lead_school
    edit_lead_school_page.lead_school.fill_in with: my_lead_school_name
  end

  def and_i_fill_in_my_lead_school_without_js
    edit_lead_school_page.no_js_lead_school.fill_in with: my_lead_school_name
  end

  def and_i_click_the_first_item_in_the_list
    using_wait_time 2 do
      edit_lead_school_page.autocomplete_list_item.click
    end
  end

  def and_i_continue
    edit_lead_school_page.submit.click
  end

  def and_a_number_of_lead_schools_exist
    @lead_schools = create_list(:school, 5, :lead_school)
  end

  def and_i_visit_the_trainee_edit_lead_school_page
    edit_lead_school_page.load(trainee_id: trainee.slug)
  end

  def my_lead_school_name
    my_lead_school.name.split(" ").first
  end

  def my_lead_school
    @my_lead_school ||= @lead_schools.sample
  end

  def then_i_am_redirected_to_the_confirm_training_details_page
    expect(confirm_training_details_page).to be_displayed(id: trainee.slug)
  end

  def then_i_am_redirected_to_the_lead_schools_page_filtered_by_my_query
    expect(lead_schools_search_page).to be_displayed(trainee_id: trainee.slug, query: my_lead_school_name)
  end
end
