# frozen_string_literal: true

require "rails_helper"

feature "add placement details" do
  background do
    given_i_am_authenticated
    given_a_trainee_exists(training_route: valid_training_routes.sample)
  end

  scenario "placement detail available" do
    when_i_visit_the_placement_details_page
    and_i_have_the_placement_details
    and_i_click_continue
    then_i_am_taken_to_the_placement_form_page
  end

  scenario "placement detail not available" do
    when_i_visit_the_placement_details_page
    and_i_do_not_have_the_placement_detail
    and_i_click_continue
    then_i_am_taken_to_the_trainee_review_drafts_page
  end

  scenario "add placement detail full journery" do
    when_i_visit_the_placement_details_page
    and_i_have_the_placement_details
    and_i_click_continue
    then_i_am_taken_to_the_placement_form_page

    when_i_enter_details_for_a_new_school
    and_i_click_continue
    then_i_see_the_confirmation_page

    and_i_click_continue
    then_i_see_the_trainee_review_drafts_page
  end

private

  def then_i_see_the_trainee_review_drafts_page
    expect(page).to have_current_path(trainee_review_drafts_path(trainee))
  end

  def when_i_click_update
    click_on "Update record"
  end

  def when_i_enter_details_for_a_new_school
    fill_in("School or setting name", with: "St. Alice's Primary School", visible: false)
    fill_in("School unique reference number (URN) - if it has one", with: "654321", visible: false)
    fill_in("Postcode", with: "OX1 1AA", visible: false)
  end

  def then_i_see_the_confirmation_page
    expect(page).to have_current_path(trainee_placements_confirm_path(trainee_id: @trainee.slug))
    expect(page).to have_content("Confirm placement details")
  end

  def when_i_visit_the_placement_details_page
    given_i_am_on_the_review_draft_page
    click_on("Placements")
  end

  def and_i_have_the_placement_details
    page.choose(t("views.forms.placement_details.label_names.has_placement_detail"))
  end

  def and_i_do_not_have_the_placement_detail
    page.choose(t("views.forms.placement_details.label_names.no_placement_detail"))
  end

  def and_i_click_continue
    click_on(t("continue"))
  end

  def then_i_am_taken_to_the_placement_form_page
    expect(page).to have_current_path(new_trainee_placement_path(trainee))
  end

  def then_i_am_taken_to_the_placement_confirm_page
    expect(page).to have_current_path(trainee_placements_confirm_path(trainee))
  end

  def then_i_am_taken_to_the_trainee_review_drafts_page
    expect(page).to have_current_path(trainee_review_drafts_path(trainee))
  end

  def valid_training_routes
    ReferenceData::TRAINING_ROUTES.names - %w[assessment_only early_years_assessment_only]
  end
end
