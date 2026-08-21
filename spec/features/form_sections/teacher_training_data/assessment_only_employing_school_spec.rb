# frozen_string_literal: true

require "rails_helper"

feature "assessment only employing school" do
  before do
    given_i_am_authenticated
  end

  scenario "choosing a GIAS school from the tasklist" do
    given_an_assessment_only_draft_exists
    and_a_school_exists
    when_i_visit_the_review_draft_page
    and_i_click_employing_school
    then_i_see_the_assessment_only_search_page

    when_i_search_for_the_school
    and_i_continue
    and_i_choose_the_school_from_the_results
    and_i_continue
    then_i_am_on_the_confirm_page
    and_i_see_the_school

    when_i_change_the_employing_school
    then_i_see_the_selected_school_rehydrated

    and_i_continue
    and_i_confirm_my_details
    then_the_employing_school_section_is_completed
  end

  scenario "manual entry overrides a previously selected GIAS school" do
    given_an_assessment_only_draft_exists
    and_a_school_exists
    when_i_visit_the_review_draft_page
    and_i_click_employing_school
    then_i_see_the_assessment_only_search_page

    when_i_search_for_the_school
    and_i_continue
    and_i_choose_the_school_from_the_results
    and_i_continue
    then_i_am_on_the_confirm_page
    and_i_see_the_school

    when_i_change_the_employing_school
    then_i_see_the_selected_school_rehydrated
    when_i_enter_a_manual_school
    and_i_continue
    then_i_am_on_the_confirm_page
    and_i_see_the_manual_school
    and_i_do_not_see_the_gias_school
  end

  scenario "entering a school that is not listed" do
    given_an_assessment_only_draft_exists
    when_i_visit_the_review_draft_page
    and_i_click_employing_school
    when_i_enter_a_manual_school
    and_i_continue
    then_i_am_on_the_confirm_page
    and_i_see_the_manual_school
  end

  scenario "submitting the search page empty" do
    given_an_assessment_only_draft_exists
    when_i_visit_the_review_draft_page
    and_i_click_employing_school
    and_i_continue
    then_i_see_the_empty_school_error
  end

  scenario "registered trainee cannot be recommended for award without an employing school" do
    given_a_trainee_exists(:trn_received, :with_valid_past_itt_start_date, employing_school: nil)
    and_i_am_on_the_trainee_record_page
    and_i_click_on_record_training_outcome
    then_i_see_the_award_is_blocked_for_employing_school
  end

private

  def given_an_assessment_only_draft_exists
    given_a_trainee_exists
  end

  def and_a_school_exists
    @school = create(:school, name: "Oakfield Primary School")
  end

  def when_i_visit_the_review_draft_page
    review_draft_page.load(id: trainee.slug)
  end

  def and_i_click_employing_school
    review_draft_page.employing_school_details_section.link.click
  end

  def then_i_see_the_assessment_only_search_page
    expect(page).to have_text("What is the trainee’s employing school?")
  end

  def when_i_search_for_the_school
    fill_in "Search for a school by its unique reference number (URN), name or postcode", with: @school.name.split.first
  end

  def and_i_choose_the_school_from_the_results
    assessment_only_employing_schools_search_page.choose_school(id: @school.id)
  end

  def and_i_continue
    click_on "Continue"
  end

  def then_i_am_on_the_confirm_page
    expect(confirm_schools_page).to be_displayed(id: trainee.slug)
  end

  def and_i_see_the_school
    expect(page).to have_text(@school.name)
  end

  def when_i_change_the_employing_school
    confirm_schools_page.employing_school_row.click_on("Change")
  end

  def then_i_see_the_selected_school_rehydrated
    expect(edit_employing_school_page.school_id.value).to eq(@school.id.to_s)
  end

  def then_the_employing_school_section_is_completed
    expect(review_draft_page).to have_employing_school_completed
  end

  def when_i_enter_a_manual_school
    find(".govuk-details__summary").click
    fill_in "School or setting name", with: "Oak House School"
    fill_in "Postcode", with: "SW1A 1AA"
  end

  def and_i_see_the_manual_school
    expect(page).to have_text("Oak House School")
    expect(page).to have_text("SW1A 1AA")
  end

  def and_i_do_not_see_the_gias_school
    expect(page).not_to have_text(@school.name)
  end

  def then_i_see_the_empty_school_error
    expect(page).to have_text("Enter an employing school")
  end

  def and_i_click_on_record_training_outcome
    record_page.record_outcome.click
  end

  def then_i_see_the_award_is_blocked_for_employing_school
    expect(page).to have_text("You cannot update the trainee’s")
    expect(page).to have_text("Employing school")
  end
end
