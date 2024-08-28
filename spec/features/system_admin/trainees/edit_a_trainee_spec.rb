# frozen_string_literal: true

require "rails_helper"

feature "Edit a trainee" do
  let(:degree_template) { build(:degree, :uk_degree_with_details) }

  before do
    given_i_am_authenticated_as_system_admin
  end

  scenario "add a new degree" do
    given_a_trainee_exists_with_a_degree
    and_i_am_on_the_trainee_record_page
    and_i_click_on_personal_details
    then_i_see_the_degree_details_page
    when_click_on_add_degree_button
    and_i_see_the_new_degree_form
    and_i_select_a_degree_type
    and_i_click_on_continue
    and_i_see_the_degree_details_page
    and_i_fill_in_degree_details
    and_i_click_on_continue
    and_i_see_the_confirm_degree_details_page
    and_i_click_on_update_record
    and_i_see_the_trainee_record_page
    and_i_click_on_personal_details
    then_i_see_the_updated_degree_details
  end

private

  def then_i_see_the_updated_degree_details
    expect(record_page.degree_detail).to have_content(degree_template.uk_degree)
    expect(record_page.degree_detail).to have_content(degree_template.subject)
    expect(record_page.degree_detail).to have_content(degree_template.institution)
    expect(record_page.degree_detail).to have_content(degree_template.grade.capitalize)
    expect(record_page.degree_detail).to have_content(degree_template.graduation_year)
  end

  def and_i_see_the_trainee_record_page
    expect(record_page).to be_displayed
    expect(record_page).to have_content("Trainee degree details updated")
  end

  def and_i_click_on_update_record
    degrees_confirm_page.update_record_button.click
  end

  def and_i_see_the_confirm_degree_details_page
    expect(degrees_confirm_page).to be_displayed
  end

  def and_i_select_a_degree_type
    degree_type_page.uk_degree.click
  end

  def and_i_click_on_continue
    degree_type_page.continue.click
  end

  def and_i_see_the_degree_details_page
    expect(degree_details_page).to be_displayed
  end

  def and_i_fill_in_degree_details
    degree_details_page.uk_degree.select(degree_template.uk_degree)
    degree_details_page.subject.select(degree_template.subject)
    degree_details_page.institution.select(degree_template.institution)
    degree_details_page.grade.choose(degree_template.grade.capitalize)
    degree_details_page.graduation_year.fill_in(with: degree_template.graduation_year)
  end

  def given_a_trainee_exists_with_a_degree
    given_a_trainee_exists(
      :submitted_for_trn,
      :without_provider,
      degrees: create_list(:degree, 1, :uk_degree_with_details),
    )
  end

  def and_i_click_on_personal_details
    record_page.personal_details_tab.click
  end

  def then_i_see_the_degree_details_page
    expect(record_page).to have_degree_detail
  end

  def when_click_on_add_degree_button
    record_page.add_degree.click
  end

  def and_i_see_the_new_degree_form
    expect(record_page).to have_content("Is this a UK degree?")
  end
end
