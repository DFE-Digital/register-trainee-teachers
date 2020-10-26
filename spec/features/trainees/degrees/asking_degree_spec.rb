require "rails_helper"

RSpec.feature "Selecting the degree route" do
  scenario "without selecting yes or no" do
    given_a_trainee_exists
    when_i_visit_the_degree_page
    and_i_click_the_continue_button
    then_i_see_the_error_summary
  end

  describe "non-UK degree" do
    scenario "without selecting no" do
      given_a_trainee_exists
      when_i_visit_the_degree_page
      and_i_click_the_continue_button
      then_i_see_the_error_summary
    end

    scenario "selecting no" do
      given_a_trainee_exists
      when_i_visit_the_degree_page
      and_i_select_no
      and_i_click_the_continue_button
      then_i_am_on_the_summary_page
    end
  end

  describe "UK degree" do
    scenario "without selecting yes" do
      given_a_trainee_exists
      when_i_visit_the_degree_page
      and_i_click_the_continue_button
      then_i_see_the_error_summary
    end

    scenario "selecting yes" do
      given_a_trainee_exists
      when_i_visit_the_degree_page
      and_i_select_yes
      and_i_click_the_continue_button
      then_i_am_on_the_degree_details_page
    end
  end

private

  def when_i_visit_the_degree_page
    degree_page.load(trainee_id: @trainee.id)
  end

  def degree_page
    @degree_page ||= PageObjects::Trainees::DegreeAsk.new
  end

  def given_a_trainee_exists
    trainee
  end

  def and_i_select_yes
    degree_page.locale_code_uk.click
    @locale = degree_page.locale_code_uk.value
  end

  def and_i_select_no
    degree_page.locale_code_non_uk.click
    @locale = degree_page.locale_code_non_uk.value
  end

  def and_i_click_the_continue_button
    degree_page.continue.click
  end

  def then_i_see_the_error_summary
    expect(degree_page.error_summary).to be_visible
  end

  def then_i_am_on_the_degree_details_page
    new_degree_details_page.load(trainee_id: trainee.id, locale_code: @locale)
    expect(new_degree_details_page).to be_displayed
  end

  def then_i_am_on_the_summary_page
    summary_page.load(id: @trainee.id)
    expect(summary_page).to be_displayed
  end

  def new_degree_details_page
    @new_degree_details_page ||= PageObjects::Trainees::NewDegreeDetails.new
  end

  def summary_page
    @summary_page ||= PageObjects::Trainees::Summary.new
  end

  def trainee
    @trainee ||= create(:trainee)
  end
end
