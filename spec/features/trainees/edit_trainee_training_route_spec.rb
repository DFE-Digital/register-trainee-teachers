# frozen_string_literal: true

require "rails_helper"

feature "edit trainee training route", type: :feature do
  background do
    given_i_am_authenticated
    given_a_trainee_exists
    and_i_visit_the_edit_training_route_page
  end

  scenario "viewing the trainee's current training route" do
    then_i_see_the_programme_details
    and_current_training_route_should_be_selected
  end

  scenario "editing the trainee's current training route", feature_routes_provider_led: true do
    then_i_select_provider_led
    and_i_submit_the_new_route
    and_i_visit_the_edit_training_route_page
    and_provider_led_should_be_selected
  end

private

  def and_i_visit_the_edit_training_route_page
    trainee_edit_training_route_page.load(id: trainee.slug)
  end

  def then_i_see_the_programme_details
    expect(trainee_edit_training_route_page).to be_displayed
  end

  def and_current_training_route_should_be_selected
    expect(trainee_edit_training_route_page.assessment_only).to be_checked
  end

  def then_i_select_provider_led
    trainee_edit_training_route_page.provider_led.click
  end

  def and_i_submit_the_new_route
    trainee_edit_training_route_page.continue_button.click
  end

  def and_provider_led_should_be_selected
    expect(trainee_edit_training_route_page.provider_led).to be_checked
  end
end
