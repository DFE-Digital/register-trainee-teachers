# frozen_string_literal: true

require "rails_helper"

feature "add placement details", feature_trainee_placement: true do
  background do
    given_i_am_authenticated
    given_a_trainee_exists(training_route: valid_training_routes.sample)
  end

  scenario "placement detail available" do
    when_i_visit_the_placement_details_page
    and_i_have_the_placement_details
    and_i_continue
    then_i_am_taken_to_the_placement_form_page
  end

  scenario "placement detail not available" do
    when_i_visit_the_placement_details_page
    and_i_do_not_have_the_placement_detail
    and_i_continue
    then_i_am_taken_to_the_placement_confirm_page
  end

private

  def when_i_visit_the_placement_details_page
    given_i_am_on_the_review_draft_page
    click_link "Placements"
  end

  def and_i_have_the_placement_details
    page.choose("Yes, I can add at least one of them now")
  end

  def and_i_do_not_have_the_placement_detail
    page.choose("No, I’ll add them later")
  end

  def and_i_continue
    click_button("Continue")
  end

  def then_i_am_taken_to_the_placement_form_page
    expect(page).to have_current_path(new_trainee_placements_path(trainee))
  end

  def then_i_am_taken_to_the_placement_confirm_page
    expect(page).to have_current_path(trainee_placements_confirm_path(trainee))
  end

  def valid_training_routes
    TRAINING_ROUTE_ENUMS.keys - %i[assessment_only early_years_assessment_only]
  end
end
