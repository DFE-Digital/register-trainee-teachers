# frozen_string_literal: true

require "rails_helper"

feature "completing the placements section", feature_trainee_placement: true do
  background do
    given_i_am_authenticated
    given_a_trainee_exists(training_route: valid_training_routes.sample)
  end

  scenario "renders a 'incomplete' status when placement details are not provided" do
    when_i_am_on_the_review_draft_page
    then_the_placements_section_should_be(incomplete)
  end

  scenario "renders an 'in progress' status when placement details partially provided" do
    when_i_visit_the_placement_details_page
    and_i_do_not_have_the_placement_detail
    and_i_continue
    and_i_do_not_confirm_my_details
    then_the_placements_section_should_be(in_progress)
  end

  scenario "renders a completed status when placement details provided" do
    when_i_visit_the_placement_details_page
    and_i_do_not_have_the_placement_detail
    and_i_continue
    and_i_confirm_my_details
    then_the_placements_section_should_be(completed)
  end

  scenario "back links" do
    given_i_am_reviewing_my_changes_on_the_confirmation_page
    when_i_click_to_add_a_placement
    then_i_see_the_placements_form_page
    when_i_click_back
    then_i_see_the_confirmation_page
  end

private

  def when_i_visit_the_placement_details_page
    given_i_am_on_the_review_draft_page
    click_link("Placements")
  end

  def and_i_have_the_placement_details
    page.choose(t("views.forms.placement_details.label_names.has_placement_detail"))
  end

  def and_i_do_not_have_the_placement_detail
    page.choose(t("views.forms.placement_details.label_names.no_placement_detail"))
  end

  def and_i_continue
    click_button(t("continue"))
  end

  def and_i_do_not_confirm_my_details
    expect(page).to have_current_path(trainee_placements_confirm_path(trainee))
    and_i_continue
  end

  def and_i_confirm_my_details
    page.check("I have completed this section")
    and_i_continue
  end

  def then_the_placements_section_should_be(status)
    within(".app-task-list__item.placement-details") do
      expect(page).to have_text(status)
    end
  end

  def given_i_am_reviewing_my_changes_on_the_confirmation_page
    when_i_visit_the_placement_details_page
    and_i_do_not_have_the_placement_detail
    and_i_continue
  end

  def when_i_click_to_add_a_placement
    within(".govuk-summary-list__row.placements") do
      click_link("Add a placement")
    end
  end

  def then_i_see_the_placements_form_page
    expect(page).to have_current_path(new_trainee_placement_path(trainee))
  end

  def when_i_click_back
    click_link "Back"
  end

  def then_i_see_the_confirmation_page
    expect(page).to have_current_path(trainee_placements_confirm_path(trainee))
  end

  def valid_training_routes
    TRAINING_ROUTE_ENUMS.keys - %i[assessment_only early_years_assessment_only]
  end
end
