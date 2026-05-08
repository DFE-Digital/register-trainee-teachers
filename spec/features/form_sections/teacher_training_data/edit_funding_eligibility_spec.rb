# frozen_string_literal: true

require "rails_helper"

feature "edit funding eligibility" do
  background { given_i_am_authenticated }

  context "with a draft trainee" do
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

    scenario "changing eligibility to not eligible removes the funding method from the confirm page" do
      given_a_draft_trainee_applying_for_scholarship_exists

      when_i_visit_the_funding_eligibility_page
      and_i_select_not_eligible
      and_i_submit_the_form
      then_i_am_on_the_training_initiative_page

      when_i_visit_the_funding_confirm_page
      then_the_funding_method_row_is_not_displayed
    end
  end

  context "with a non-draft trainee" do
    scenario "changing eligibility shows the new value on the confirm page" do
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

    scenario "changing eligibility to not eligible redirects to confirm and removes the funding method" do
      given_a_non_draft_trainee_applying_for_scholarship_exists

      when_i_visit_the_funding_eligibility_page
      and_i_select_not_eligible
      and_i_submit_the_form
      then_i_am_on_the_training_initiative_page

      when_i_update_the_training_initiative
      and_i_submit_the_form
      then_i_am_redirected_to_the_funding_confirmation_page

      when_i_save_the_funding_section
      when_i_visit_the_funding_confirm_page
      then_the_funding_method_row_shows_not_applicable
    end
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
    expect(page).to have_text("We need to record whether this trainee is eligible for funding, based on student finance criteria.You must provide funding eligibility information for every trainee.")
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

  def given_a_draft_trainee_applying_for_scholarship_exists
    given_a_trainee_exists(
      :provider_led_postgrad,
      :with_provider_led_bursary,
      :with_valid_itt_start_date,
      funding_eligibility: :eligible,
      applying_for_bursary: false,
      applying_for_scholarship: true,
    )
  end

  def given_a_non_draft_trainee_applying_for_scholarship_exists
    given_a_trainee_exists(
      :submitted_for_trn,
      :provider_led_postgrad,
      :with_provider_led_bursary,
      :with_valid_itt_start_date,
      funding_eligibility: :eligible,
      applying_for_bursary: false,
      applying_for_scholarship: true,
    )
  end

  def then_the_funding_method_row_is_not_displayed
    expect(confirm_funding_page).to be_displayed(id: trainee.slug)
    expect(page).not_to have_css(".funding-method")
  end

  def then_the_funding_method_row_shows_not_applicable
    expect(confirm_funding_page).to be_displayed(id: trainee.slug)
    within(".funding-method") do
      expect(page).to have_text("Not applicable")
    end
  end

  def when_i_update_the_training_initiative
    edit_funding_page.training_initiative_radios.choose(
      "funding-training-initiatives-form-training-initiative-now-teach-field",
    )
  end

  def then_i_am_redirected_to_the_funding_confirmation_page
    expect(confirm_funding_page).to be_displayed(id: trainee.slug)
  end

  def when_i_save_the_funding_section
    confirm_funding_page.continue.click
  end
end
