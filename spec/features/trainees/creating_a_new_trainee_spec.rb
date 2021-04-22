# frozen_string_literal: true

require "rails_helper"

feature "Create trainee journey" do
  background do
    given_i_am_authenticated
    when_i_am_viewing_the_list_of_trainees
    and_i_click_on_add_trainee_button
  end

  scenario "setting up an initial assessment only record" do
    and_i_select_assessment_only_route
    and_i_save_the_form
    then_i_should_see_the_new_trainee_overview
  end

  scenario "setting up an initial provider led record", 'feature_routes.provider_led_postgrad': true do
    and_i_select_provider_led_postgrad_route
    and_i_save_the_form
    then_i_should_see_the_new_trainee_overview
  end

  scenario "setting up an initial early years undergrad record", 'feature_routes.early_years_undergrad': true do
    and_i_select_early_years_undergrad_route
    and_i_save_the_form
    then_i_should_see_the_new_trainee_overview
  end

  scenario "provider led postgrad radio button not shown when feature set to false", 'feature_routes.provider_led_postgrad': false do
    and_i_should_not_see_provider_led_postgrad_route
  end

  scenario "early years undergrad radio button not shown when feature set to false", 'feature_routes.early_years_undergrad': false do
    and_i_should_not_see_early_years_undergrad_route
  end

  scenario "early years assessment only radio button not shown when feature set to false", 'feature_routes.early_years_assessment_only': false do
    and_i_should_not_see_early_years_assessment_only_route
  end

  scenario "early years graduate employment based radio button not shown when feature set to false", 'feature_routes.early_years_graduate_employment_based': false do
    and_i_should_not_see_early_years_graduate_employment_based_route
  end

  scenario "early years graduate entry radio button not shown when feature set to false", 'feature_routes.early_years_graduate_entry': false do
    and_i_should_not_see_early_years_graduate_entry_route
  end

  scenario "school direct salaried radio button not shown when feature set to false", 'feature_routes.school_direct_salaried': false do
    and_i_should_not_see_school_direct_salaried_route
  end

  scenario "school direct tuition fee radio button not shown when feature set to false", 'feature_routes.school_direct_tuition_fee': false do
    and_i_should_not_see_school_direct_tuition_fee_route
  end

  scenario "submitting without choosing a route" do
    and_i_save_the_form
    then_i_should_see_a_validation_error
  end

private

  def when_i_am_viewing_the_list_of_trainees
    trainee_index_page.load
  end

  def and_i_click_on_add_trainee_button
    trainee_index_page.add_trainee_link.click
  end

  def and_i_select_assessment_only_route
    new_trainee_page.assessment_only.click
  end

  def and_i_select_provider_led_postgrad_route
    new_trainee_page.provider_led_postgrad.click
  end

  def and_i_select_early_years_undergrad_route
    new_trainee_page.early_years_undergrad.click
  end

  def and_i_should_not_see_provider_led_postgrad_route
    expect(new_trainee_page).to be_displayed
    expect(new_trainee_page).to_not have_provider_led_postgrad
  end

  def and_i_should_not_see_early_years_undergrad_route
    expect(new_trainee_page).to be_displayed
    expect(new_trainee_page).to_not have_early_years_undergrad
  end

  def and_i_should_not_see_early_years_assessment_only_route
    expect(new_trainee_page).to be_displayed
    expect(new_trainee_page).to_not have_early_years_assessment_only
  end

  def and_i_should_not_see_early_years_graduate_entry_route
    expect(new_trainee_page).to be_displayed
    expect(new_trainee_page).to_not have_early_years_graduate_entry
  end

  def and_i_should_not_see_early_years_graduate_employment_based_route
    expect(new_trainee_page).to be_displayed
    expect(new_trainee_page).to_not have_early_years_graduate_employment_based
  end

  def and_i_should_not_see_school_direct_salaried_route
    expect(new_trainee_page).to be_displayed
    expect(new_trainee_page).to_not have_school_direct_salaried
  end

  def and_i_should_not_see_school_direct_tuition_fee_route
    expect(new_trainee_page).to be_displayed
    expect(new_trainee_page).to_not have_school_direct_tuition_fee
  end

  def and_i_save_the_form
    new_trainee_page.continue_button.click
  end

  def then_i_should_see_the_new_trainee_overview
    expect(review_draft_page).to be_displayed
  end

  def then_i_should_see_a_validation_error
    expect(new_trainee_page).to have_content(I18n.t("activerecord.errors.models.trainee.attributes.training_route"))
  end
end
