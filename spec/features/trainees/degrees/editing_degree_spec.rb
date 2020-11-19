# frozen_string_literal: true

require "rails_helper"

RSpec.feature "editing a degree" do
  context "UK degree" do
    scenario "the user enters valid details" do
      given_a_trainee_with_a_uk_degree
      when_i_visit_the_edit_degree_details_page
      and_i_enter_valid_uk_degree_details
      and_i_click_the_continue_button
      then_i_am_redirected_to_confirm_page
    end

    scenario "the user enters invalid details" do
      given_a_trainee_with_a_uk_degree
      when_i_visit_the_edit_degree_details_page
      and_i_click_the_continue_button
      then_i_see_the_error_summary
    end
  end

  context "Non UK degree" do
    scenario "the user enters valid details" do
      given_a_trainee_with_a_non_uk_degree
      when_i_visit_the_edit_degree_details_page
      and_i_enter_valid_non_uk_degree_details
      and_i_click_the_continue_button
      then_i_am_redirected_to_confirm_page
    end

    scenario "the user enters invalid details" do
      given_a_trainee_with_a_non_uk_degree
      when_i_visit_the_edit_degree_details_page
      and_i_click_the_continue_button
      then_i_see_the_error_summary
    end
  end

private

  def given_a_trainee_with_a_uk_degree
    uk_trainee
  end

  def given_a_trainee_with_a_non_uk_degree
    non_uk_trainee
  end

  def and_i_click_the_continue_button
    edit_degree_details_page.continue.click
  end

  def and_i_enter_valid_non_uk_degree_details
    template = build(:degree, :non_uk_degree_with_details)
    edit_degree_details_page.subject.select(template.subject)
    edit_degree_details_page.country.select(template.country)
    edit_degree_details_page.graduation_year.fill_in(with: template.graduation_year)
  end

  def and_i_enter_valid_uk_degree_details
    template = build(:degree, :uk_degree_with_details)

    edit_degree_details_page.subject.select(template.subject)
    edit_degree_details_page.institution.select(template.institution)
    edit_degree_details_page.grade.choose(template.grade)
    edit_degree_details_page.graduation_year.fill_in(with: template.graduation_year)
  end

  def when_i_visit_the_edit_degree_details_page
    edit_degree_details_page.load(trainee_id: trainee.id,
                                  id: trainee.degrees.first.id)
  end

  def then_i_am_redirected_to_confirm_page
    degrees_confirm.load(trainee_id: trainee.id)
    expect(degrees_confirm).to be_displayed(trainee_id: trainee.id)
  end

  def then_i_see_the_error_summary
    expect(edit_degree_details_page.error_summary).to be_visible
  end

  def edit_degree_details_page
    @edit_degree_details_page ||= PageObjects::Trainees::EditDegreeDetails.new
  end

  def degrees_confirm
    @degrees_confirm ||= PageObjects::Trainees::DegreesConfirm.new
  end

  def trainee
    (@uk_trainee || @non_uk_trainee)
  end

  def uk_trainee
    @uk_trainee ||= create(:degree, :uk_degree_type).trainee
  end

  def non_uk_trainee
    @non_uk_trainee ||= create(:degree, :non_uk_degree_type).trainee
  end
end
