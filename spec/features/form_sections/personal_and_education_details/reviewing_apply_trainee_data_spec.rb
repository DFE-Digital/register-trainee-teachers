# frozen_string_literal: true

require "rails_helper"

feature "edit training details" do
  include SummaryHelper

  let(:new_trainee_id) { "#{trainee.provider_trainee_id}new" }

  background { given_i_am_authenticated }

  scenario "reviewing details" do
    given_a_trainee_with_degrees_exist
    when_i_visit_the_apply_trainee_data_page
    and_i_review_the_trainee_data
    then_i_am_redirected_to_the_review_draft_page
    and_the_relevant_sections_are_completed
  end

  scenario "reviewing with invalid data" do
    given_a_trainee_with_invalid_data_from_apply_exist
    when_i_visit_the_apply_trainee_data_page
    and_i_review_the_trainee_data
    then_i_see_error_messages
  end

  scenario "changing an attribute" do
    given_a_trainee_with_degrees_exist
    when_i_visit_the_apply_trainee_data_page
    and_i_click_to_change_the_trainee_full_name
    and_i_change_the_first_name_to("Jeff")
    then_i_am_back_on_the_apply_trainee_data_page
  end

  scenario "changing an attribute for a Citizen of Guinea-Bissau" do
    given_a_trainee_with_degrees_exist(nationality: build(:nationality, :citizen_of_guinea_bissau))
    when_i_visit_the_apply_trainee_data_page
    and_i_click_to_change_the_trainee_full_name
    and_i_change_the_first_name_to("Jeff")
    then_i_am_back_on_the_apply_trainee_data_page
  end

private

  def given_a_trainee_with_degrees_exist(nationality: build(:nationality))
    given_a_trainee_exists(
      :with_diversity_information,
      :with_apply_application,
      nationalities: [nationality],
      degrees: [build(:degree, :uk_degree_with_details)],
    )
  end

  def given_a_trainee_with_invalid_data_from_apply_exist
    given_a_trainee_exists(:with_invalid_apply_application)
  end

  def when_i_visit_the_apply_trainee_data_page
    apply_trainee_data_page.load(id: trainee.slug)
  end

  def and_i_review_the_trainee_data
    apply_trainee_data_page.i_have_reviewed_checkbox.check
    apply_trainee_data_page.continue.click
  end

  def then_i_am_redirected_to_the_review_draft_page
    expect(review_draft_page).to be_displayed(id: trainee.slug)
  end

  def and_the_relevant_sections_are_completed
    expect(review_draft_page.apply_trainee_data.status.text).to eq("Status Completed")
  end

  def then_i_see_error_messages
    expect(apply_trainee_data_page).to have_content(I18n.t("views.apply_invalid_data_view.invalid_answers_summary", count: 2))
  end

  def and_i_click_to_change_the_trainee_full_name
    apply_trainee_data_page.full_name_change_link.click
  end

  def and_i_change_the_first_name_to(name)
    personal_details_page.first_names.set(name)
    personal_details_page.continue_button.click
  end

  def then_i_am_back_on_the_apply_trainee_data_page
    expect(apply_trainee_data_page).to be_displayed(id: trainee.slug)
  end
end
