# frozen_string_literal: true

require "rails_helper"

feature "edit funding eligibility" do
  background { given_i_am_authenticated }

  scenario "edit with valid parameters" do
    given_a_trainee_exists(
      :provider_led_postgrad,
      :with_valid_itt_start_date,
      progress: Progress.new(course_details: true),
    )
    when_i_visit_the_review_draft_page
    and_i_click_the_funding_section
    then_i_see_the_funding_eligibility_page
    and_i_see_the_heading
    and_i_see_the_description
    and_i_see_the_question

    when_i_submit_the_form
    then_i_see_error_messages

    when_i_select_eligible
    and_i_submit_the_form
    then_i_am_on_the_training_initiative_page
    and_the_trainee_has_the_correct_funding_eligibility("eligible")

    when_i_click_back
    then_i_see_the_funding_eligibility_page
    and_eligible_is_selected

    when_i_click_back
    then_i_see_the_review_draft_page

    and_i_click_the_funding_section
    then_i_see_the_funding_eligibility_page
    and_eligible_is_selected
  end

  scenario "non-draft trainee changing eligibility shows new value on confirm page" do
    given_a_trainee_exists(
      :submitted_for_trn,
      :provider_led_postgrad,
      :with_valid_itt_start_date,
      funding_eligibility: :eligible,
    )

    when_i_visit_the_funding_eligibility_page
    and_i_select_not_eligible
    and_i_submit_the_form
    then_i_am_on_the_training_initiative_page

    when_i_visit_the_funding_confirm_page
    then_i_see_the_new_funding_eligibility_on_the_confirm_page
  end

  scenario "non-draft trainee show page banner lists funding eligibility when not_eligible has a funding method" do
    given_a_submitted_trainee_with_bursary_and_not_eligible_funding
    when_i_visit_the_trainee_show_page
    then_the_missing_data_banner_lists_funding_eligibility
  end

  scenario "draft trainee with not_eligible and a funding method for non-exception course shows error when confirming" do
    given_a_draft_trainee_with_bursary_and_not_eligible_funding
    when_i_visit_the_funding_confirm_page
    and_i_mark_as_completed_and_continue
    then_i_see_the_section_contains_questions_message
    and_i_see_funding_eligibility_in_the_missing_fields
  end

private

  def when_i_visit_the_review_draft_page
    review_draft_page.load(id: trainee.slug)
  end

  def and_i_click_the_funding_section
    review_draft_page.funding_section.link.click
  end

  def then_i_see_the_funding_eligibility_page
    expect(funding_eligibility_page).to be_displayed(id: trainee.slug)
  end

  def and_i_see_the_heading
    expect(page).to have_css("h1", text: "Funding eligibility")
  end

  def and_i_see_the_description
    expect(page).to have_text("A funding eligibility code records a trainee's status using Department of Education (DfE) student finance criteria.")
  end

  def and_i_see_the_question
    expect(page).to have_text("Is this trainee eligible for funding?")
  end

  def when_i_submit_the_form
    funding_eligibility_page.submit_button.click
  end

  alias_method :and_i_submit_the_form, :when_i_submit_the_form

  def then_i_see_error_messages
    expect(page).to have_text("Select the funding eligibility for this trainee")
  end

  def when_i_select_eligible
    choose("Yes")
  end

  def then_i_am_on_the_training_initiative_page
    expect(training_initiative_page).to be_displayed(id: trainee.slug)
  end

  def and_the_trainee_has_the_correct_funding_eligibility(eligibility)
    trainee.reload
    expect(trainee.funding_eligibility).to eq(eligibility)
  end

  def when_i_click_back
    click_link("Back")
  end

  def then_i_see_the_review_draft_page
    expect(review_draft_page).to be_displayed(id: trainee.slug)
  end

  def and_eligible_is_selected
    expect(funding_eligibility_page.eligible).to be_checked
  end

  def when_i_visit_the_funding_eligibility_page
    funding_eligibility_page.load(id: trainee.slug)
  end

  def and_i_select_not_eligible
    choose("No")
  end

  def when_i_visit_the_funding_confirm_page
    confirm_funding_page.load(id: trainee.slug)
  end

  def then_i_see_the_new_funding_eligibility_on_the_confirm_page
    within(".funding-eligibility") do
      expect(page).to have_text("No")
      expect(page).not_to have_text("Yes")
    end
  end

  def given_a_draft_trainee_with_bursary_and_not_eligible_funding
    given_a_trainee_exists(
      :provider_led_postgrad,
      :with_start_date,
      :with_study_mode_and_course_dates,
      funding_eligibility: :not_eligible,
      applying_for_bursary: true,
      training_initiative: ROUTE_INITIATIVES_ENUMS[:no_initiative],
    )
    allocation_subject = trainee.course_allocation_subject || create(:allocation_subject)
    subject_specialism = create(:subject_specialism, allocation_subject:)
    trainee.update!(course_allocation_subject: allocation_subject, course_subject_one: subject_specialism.name)
    funding_method = create(:funding_method, :bursary, training_route: :provider_led_postgrad, academic_cycle: trainee.start_academic_cycle)
    create(:funding_method_subject, allocation_subject:, funding_method:)
  end

  def then_i_see_the_section_contains_questions_message
    expect(page).to have_text("There is a problem")
    expect(page).to have_text("This section contains 1 question that you need to complete")
  end

  def and_i_mark_as_completed_and_continue
    confirm_funding_page.confirm.click
    confirm_funding_page.continue.click
  end

  def and_i_see_funding_eligibility_in_the_missing_fields
    expect(page).to have_link("Funding eligibility is missing")
  end

  def when_i_visit_the_trainee_show_page
    visit(trainee_path(trainee))
  end

  def then_the_missing_data_banner_lists_funding_eligibility
    expect(page).to have_text("You need to enter")
    expect(page).to have_link("Funding eligibility")
  end

  def given_a_submitted_trainee_with_bursary_and_not_eligible_funding
    given_a_trainee_exists(
      :submitted_for_trn,
      :provider_led_postgrad,
      :with_start_date,
      :with_study_mode_and_course_dates,
      funding_eligibility: :not_eligible,
      applying_for_bursary: true,
      training_initiative: ROUTE_INITIATIVES_ENUMS[:no_initiative],
    )
    allocation_subject = trainee.course_allocation_subject || create(:allocation_subject)
    subject_specialism = create(:subject_specialism, allocation_subject:)
    trainee.update!(course_allocation_subject: allocation_subject, course_subject_one: subject_specialism.name)
    funding_method = create(:funding_method, :bursary, training_route: :provider_led_postgrad, academic_cycle: trainee.start_academic_cycle)
    create(:funding_method_subject, allocation_subject:, funding_method:)
  end
end
