# frozen_string_literal: true

require "rails_helper"

feature "confirm placements" do
  background do
    given_i_am_authenticated
    given_a_trainee_exists
  end

  scenario "changing status" do
    given_i_have_two_placements
    and_i_am_on_the_confirm_placement_details_page
    and_the_i_have_completed_this_section_checkbox_is_unchecked
    and_i_check_the_i_have_completed_this_section_checkbox
    when_i_click_on_continue
    then_i_am_redirected_to_review_draft
    and_i_visit_the_confirm_placement_details_page
    and_the_i_have_completed_this_section_checkbox_is_checked
  end

  scenario "adding a placements" do
    given_i_am_on_the_confirm_placement_details_page
    when_i_click_on_add_a_placement_button
    then_i_am_redirected_to_add_a_placement_page
  end

private

  def given_i_have_two_placements
    create_list(:placement, 2, trainee: @trainee)
  end

  def given_i_am_on_the_confirm_placement_details_page
    visit "/trainees/#{trainee.slug}/placements/confirm"
  end
  alias_method :and_i_am_on_the_confirm_placement_details_page, :given_i_am_on_the_confirm_placement_details_page

  def and_the_i_have_completed_this_section_checkbox_is_unchecked
    expect(page.find_by_id("confirm-detail-form-mark-as-completed-1-field")).not_to be_checked
  end

  def and_the_i_have_completed_this_section_checkbox_is_checked
    expect(page.find_by_id("confirm-detail-form-mark-as-completed-1-field")).to be_checked
  end

  def and_i_check_the_i_have_completed_this_section_checkbox
    page.check("I have completed this section")
  end

  def when_i_click_on_continue
    page.click_button("Continue")
  end

  def then_i_am_redirected_to_review_draft
    expect(page).to have_current_path("/trainees/#{trainee.slug}/review-draft")
  end

  def when_i_click_on_add_a_placement_button
    page.click_on("Add a placement", class: "govuk-button--secondary govuk-button")
  end

  def then_i_am_redirected_to_add_a_placement_page
    expect(page).to have_current_path("/trainees/#{trainee.slug}/placements/new")
  end

  def then_i_am_redirected_to_404_page
    expect(page).to have_current_path("/404")
  end

  alias_method :and_i_visit_the_confirm_placement_details_page, :given_i_am_on_the_confirm_placement_details_page
end
