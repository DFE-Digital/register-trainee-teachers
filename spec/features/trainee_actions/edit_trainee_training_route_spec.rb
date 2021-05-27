# frozen_string_literal: true

require "rails_helper"

feature "editing a trainee training route", type: :feature do
  background do
    given_i_am_authenticated
    given_a_trainee_exists(traits)
    and_i_visit_the_edit_training_route_page
  end

  context "draft-trainee" do
    let(:traits) { :draft }

    scenario "viewing the draft-trainee's current training route" do
      then_i_see_the_course_details
      and_current_training_route_should_be_selected
    end

    scenario "editing a draft-trainee's current training route", 'feature_routes.provider_led_postgrad': true do
      then_i_select_provider_led_postgrad
      and_i_submit_the_new_route
      and_i_visit_the_edit_training_route_page
      and_provider_led_postgrad_should_be_selected
    end
  end

  context "non-draft trainee" do
    let(:traits) { :submitted_for_trn }

    scenario "redirect when editing a non-draft trainee's training route" do
      expect(record_page).to be_displayed(id: trainee.slug)
    end
  end

private

  def and_i_visit_the_edit_training_route_page
    trainee_edit_training_route_page.load(id: trainee.slug)
  end

  def then_i_see_the_course_details
    expect(trainee_edit_training_route_page).to be_displayed
  end

  def and_current_training_route_should_be_selected
    expect(trainee_edit_training_route_page.assessment_only).to be_checked
  end

  def then_i_select_provider_led_postgrad
    trainee_edit_training_route_page.provider_led_postgrad.click
  end

  def and_i_submit_the_new_route
    trainee_edit_training_route_page.continue_button.click
  end

  def and_provider_led_postgrad_should_be_selected
    expect(trainee_edit_training_route_page.provider_led_postgrad).to be_checked
  end
end
