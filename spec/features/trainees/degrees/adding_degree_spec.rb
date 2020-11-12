require "rails_helper"

RSpec.feature "Adding a degree" do
  background { given_i_am_authenticated }

  describe "Validation before route is picked" do
    scenario "the user enters invalid details" do
      given_a_trainee_exists
      and_i_visit_the_summary_page
      and_i_click_the_degree_on_the_summary_page
      when_i_visit_the_type_page
      and_i_click_the_continue_button_on_the_type_page
      then_i_see_the_error_summary_for_type_page
    end
  end

  describe "UK Route" do
    scenario "the user enters valid details on UK degree details page" do
      given_a_trainee_exists
      and_i_have_selected_uk_route
      when_i_visit_the_degree_details_page
      and_i_fill_in_the_form
      and_i_click_the_continue_button_on_the_degree_details_page
      then_i_am_redirected_to_the_trainee_degrees_confirmation_page
      and_confirm_my_details
      then_i_am_redirected_to_the_summary_page
    end

    scenario "the user enters invalid details on UK degree details page" do
      given_a_trainee_exists
      and_i_have_selected_uk_route
      when_i_visit_the_degree_details_page
      and_i_click_the_continue_button_on_the_degree_details_page
      then_i_see_the_error_summary_for_degree_details_page
    end
  end

  describe "Non-UK Route" do
    scenario "the user enters valid details on Non-UK degree details page" do
      given_a_trainee_exists
      and_i_have_selected_non_uk_route
      when_i_visit_the_degree_details_page
      and_i_fill_in_the_form
      and_i_click_the_continue_button_on_the_degree_details_page
      then_i_am_redirected_to_the_trainee_degrees_confirmation_page
      and_confirm_my_details
      then_i_am_redirected_to_the_summary_page
    end

    scenario "the user enters invalid details on Non-UK degree details page" do
      given_a_trainee_exists
      and_i_have_selected_non_uk_route
      when_i_visit_the_degree_details_page
      and_i_click_the_continue_button_on_the_degree_details_page
      then_i_see_the_error_summary_for_degree_details_page
    end
  end

private

  def given_a_trainee_exists
    trainee
  end

  def and_i_visit_the_summary_page
    summary_page.load(id: @trainee.id)
    expect(summary_page).to be_displayed(id: @trainee.id)
  end

  def and_i_click_the_degree_on_the_summary_page
    summary_page.degree_link.click
  end

  def when_i_visit_the_type_page
    type_page.load(trainee_id: @trainee.id)
  end

  def and_i_click_the_continue_button_on_the_type_page
    type_page.continue.click
  end

  def then_i_see_the_error_summary_for_type_page
    expect(type_page.error_summary).to be_visible
  end

  def and_i_click_the_continue_button_on_the_degree_details_page
    degree_details_page.continue.click
  end

  def then_i_see_the_error_summary_for_degree_details_page
    expect(degree_details_page.error_summary).to be_visible
  end

  def and_i_have_selected_uk_route
    @locale = "uk"
  end

  def and_i_have_selected_non_uk_route
    @locale = "non_uk"
  end

  def and_i_fill_in_the_form
    if @locale == "uk"
      and_i_fill_in_the_uk_form
    else
      and_i_fill_in_the_non_uk_form
    end
  end

  def and_i_fill_in_the_uk_form
    template = build(:degree, :uk_degree_with_details)

    degree_details_page.uk_degree.select(template.uk_degree)
    degree_details_page.subject.select(template.subject)
    degree_details_page.institution.select(template.institution)
    degree_details_page.grade.choose(template.grade)
    degree_details_page.graduation_year.fill_in(with: template.graduation_year)
  end

  def and_i_fill_in_the_non_uk_form
    template = build(:degree, :non_uk_degree_with_details)

    degree_details_page.public_send(template.non_uk_degree.parameterize(separator: "_")).choose
    degree_details_page.subject.select(template.subject)
    degree_details_page.country.select(template.country)
    degree_details_page.graduation_year.fill_in(with: template.graduation_year)
  end

  def when_i_visit_the_degree_details_page
    degree_details_page.load(trainee_id: trainee.id, locale_code: @locale)
    expect(degree_details_page).to be_displayed(trainee_id: trainee.id, locale_code: @locale)
  end

  def then_i_am_redirected_to_the_summary_page
    expect(current_path).to eq("/trainees/#{trainee.id}")
  end

  def then_i_am_redirected_to_the_trainee_degrees_confirmation_page
    expect(current_path).to eq("/trainees/#{trainee.id}/degrees/confirm")
  end

  def and_confirm_my_details
    @confirm_page ||= PageObjects::Trainees::ConfirmDetails.new
    expect(@confirm_page).to be_displayed(id: @trainee.id, section: "degrees")
    @confirm_page.submit_button.click
  end

  def degree_details_page
    @degree_details_page ||= PageObjects::Trainees::NewDegreeDetails.new
  end

  def summary_page
    @summary_page ||= PageObjects::Trainees::Summary.new
  end

  def type_page
    @type_page ||= PageObjects::Trainees::DegreeType.new
  end

  def trainee
    @trainee ||= create(:trainee, provider: current_user.provider)
  end
end
