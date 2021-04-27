# frozen_string_literal: true

require "rails_helper"

feature "editing a degree" do
  background { given_i_am_authenticated }

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

    # As we are not doing an autocomplete validation on uk_degree (type)
    # the uk form is a superset of the non_uk one, so we just need one
    # test for autocompletes
    scenario "user partially submits autocompletes", js: true do
      given_a_trainee_with_a_uk_degree
      when_i_visit_the_edit_degree_details_page
      and_i_fill_in_subject_without_selecting_a_value(with: "moose")
      and_i_fill_in_institution_without_selecting_a_value(with: "obtuse")
      and_i_click_the_continue_button
      then_subject_is_populated(with: "moose")
      then_institution_is_populated(with: "obtuse")
      then_i_see_error_messages_for_partially_submitted_fields(:subject, :institution)
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
    edit_degree_details_page.load(trainee_id: trainee.slug,
                                  id: trainee.degrees.first.slug)
  end

  def then_i_am_redirected_to_confirm_page
    degrees_confirm_page.load(trainee_id: trainee.slug)
    expect(degrees_confirm_page).to be_displayed(trainee_id: trainee.slug)
  end

  def then_i_see_the_error_summary
    expect(edit_degree_details_page.error_summary).to be_visible
  end

  def trainee
    (@uk_trainee || @non_uk_trainee)
  end

  def uk_trainee
    @uk_trainee ||= create(:trainee, provider: current_user.provider).tap do |t|
      t.degrees << build(:degree, :uk_degree_type)
    end
  end

  def non_uk_trainee
    @non_uk_trainee ||= create(:trainee, provider: current_user.provider).tap do |t|
      t.degrees << build(:degree, :non_uk_degree_type)
    end
  end

  def then_i_see_error_messages_for_partially_submitted_fields(*fields)
    fields.each do |f|
      message = I18n.t(
        "activemodel.errors.validators.autocomplete.#{f}",
      )
      expect(degree_details_page).to have_content(message)
    end
  end

  def and_i_fill_in_subject_without_selecting_a_value(with:)
    degree_details_page.subject_raw.fill_in with: with
  end

  def then_subject_is_populated(with:)
    expect(degree_details_page.subject_raw.value).to eq(with)
  end

  def and_i_fill_in_institution_without_selecting_a_value(with:)
    degree_details_page.institution_raw.fill_in with: with
  end

  def then_institution_is_populated(with:)
    expect(degree_details_page.institution_raw.value).to eq(with)
  end
end
