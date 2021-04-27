# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Non-JS lead schools search" do
  before do
    given_i_am_authenticated
    given_a_school_direct_salaried_trainee_exists
    and_a_number_of_lead_school_exists
    and_i_am_on_the_lead_schools_page_filtered_by_my_query
  end

  scenario "choosing a lead school" do
    and_i_choose_my_lead_school
    and_i_continue
    then_i_am_redirected_to_the_confirm_training_details_page
  end

private

  def given_a_school_direct_salaried_trainee_exists
    given_a_trainee_exists(:school_direct_salaried)
  end

  def and_i_choose_my_lead_school
    lead_schools_search_page.choose_school(id: my_lead_school.id)
  end

  def and_i_continue
    lead_schools_search_page.continue.click
  end

  def and_a_number_of_lead_school_exists
    @lead_schools = create_list(:school, 5, lead_school: true)
  end

  def and_i_am_on_the_lead_schools_page_filtered_by_my_query
    lead_schools_search_page.load(trainee_id: trainee.slug, query: query)
  end

  def query
    my_lead_school.name.split(" ").first
  end

  def my_lead_school
    @my_lead_school ||= @lead_schools.sample
  end

  def then_i_am_redirected_to_the_confirm_training_details_page
    expect(confirm_training_details_page).to be_displayed(id: trainee.slug)
  end
end
