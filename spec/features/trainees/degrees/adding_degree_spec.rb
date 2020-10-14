require "rails_helper"

RSpec.feature "Adding a degree" do
  scenario "adding a degree" do
    given_a_trainee_exists
    when_i_visit_the_degree_page
    and_i_select_a_degree_type
    and_i_click_continue_button
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

  def and_i_select_a_degree_type
    degree_page.degree_type.choose("UK degree")
    degree_page.type_of_uk_degrees.select("Bachelor of Arts")

    degree_page.degree_type.choose("Non-UK degree")
    degree_page.type_of_non_uk_degrees.choose("Bachelor Degree")
    degree_page.type_of_non_uk_degrees.choose("NARIC not provided")
  end

  def and_i_click_continue_button
    degree_page.continue.click
    summary_page.load(id: @trainee.id)
  end

  def summary_page
    @summary_page ||= PageObjects::Trainees::Summary.new
  end

  def trainee
    @trainee ||= create(:trainee)
  end
end
