# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Non-JS employing schools search" do
  before do
    given_i_am_authenticated
    given_a_school_direct_salaried_trainee_exists
    and_a_number_of_school_exists
    and_i_am_on_the_employing_schools_page_filtered_by_my_query
  end

  scenario "choosing a lead school" do
    and_i_choose_my_employing_school
    and_i_continue
    then_i_am_redirected_to_the_confirm_training_details_page
  end

private

  def given_a_school_direct_salaried_trainee_exists
    given_a_trainee_exists(:school_direct_salaried)
  end

  def and_i_choose_my_employing_school
    employing_schools_search_page.choose_school(id: my_employing_school.id)
  end

  def and_i_continue
    employing_schools_search_page.continue.click
  end

  def and_a_number_of_school_exists
    @schools = create_list(:school, 5)
  end

  def and_i_am_on_the_employing_schools_page_filtered_by_my_query
    employing_schools_search_page.load(trainee_id: trainee.slug, query: query)
  end

  def query
    my_employing_school.name.split(" ").first
  end

  def my_employing_school
    @my_employing_school ||= @schools.sample
  end

  def then_i_am_redirected_to_the_confirm_training_details_page
    expect(confirm_training_details_page).to be_displayed(id: trainee.slug)
  end
end
