require "rails_helper"

RSpec.feature "Adding a degree" do
  scenario "without selecting a degree type" do
    given_a_trainee_exists
    when_i_visit_the_degree_page
    and_i_click_the_continue_button
    then_i_see_the_error_summary
  end

  describe "Non-UK degree" do
    scenario "without comparable UK degree type" do
      given_a_trainee_exists
      when_i_visit_the_degree_page
      and_i_select_the_non_uk_degree_type
      and_i_click_the_continue_button
      then_i_see_the_error_summary
    end

    scenario "with comparable UK degree type" do
      given_a_trainee_exists
      when_i_visit_the_degree_page
      and_i_select_the_non_uk_degree_type
      and_i_select_a_non_uk_degree
      and_i_click_the_continue_button
      then_i_am_on_the_summary_page
    end
  end

  describe "UK degree" do
    scenario "without UK degree type" do
      given_a_trainee_exists
      when_i_visit_the_degree_page
      and_i_select_the_uk_degree_type
      and_i_click_the_continue_button
      then_i_see_the_error_summary
    end

    scenario "with UK degree type" do
      given_a_trainee_exists
      when_i_visit_the_degree_page
      and_i_select_the_uk_degree_type
      and_i_select_an_uk_degree
      and_i_click_the_continue_button
      then_i_am_on_the_degree_details_page
    end
  end

private

  def when_i_visit_the_degree_page
    degree_page.load(trainee_id: @trainee.id)
  end

  def degree_page
    @degree_page ||= PageObjects::Trainees::Degrees.new
  end

  def given_a_trainee_exists
    trainee
  end

  def and_i_select_the_uk_degree_type
    degree_page.uk_degree_type.click
  end

  def and_i_select_the_non_uk_degree_type
    degree_page.non_uk_degree_type.click
  end

  def and_i_click_the_continue_button
    degree_page.continue.click
  end

  def then_i_see_the_error_summary
    expect(degree_page.error_summary).to be_visible
  end

  def then_i_am_on_the_degree_details_page
    degree_details_page.load(trainee_id: trainee.id,
                             id: trainee.degrees.first.id)
    expect(degree_details_page).to be_displayed
  end

  def then_i_am_on_the_summary_page
    summary_page.load(id: @trainee.id)
    expect(summary_page).to be_displayed
  end

  def degree_details_page
    @degree_details_page ||= PageObjects::Trainees::DegreeDetails.new
  end

  def and_i_select_a_non_uk_degree
    degree_page.type_of_non_uk_degrees.choose(non_uk_degree_type)
  end

  def and_i_select_an_uk_degree
    degree_page.type_of_uk_degrees.select(uk_degree_type)
  end

  def uk_degree_type
    "Bachelor of Arts"
  end

  def non_uk_degree_type
    "Bachelor Degree"
  end

  def summary_page
    @summary_page ||= PageObjects::Trainees::Summary.new
  end

  def trainee
    @trainee ||= create(:trainee)
  end
end
