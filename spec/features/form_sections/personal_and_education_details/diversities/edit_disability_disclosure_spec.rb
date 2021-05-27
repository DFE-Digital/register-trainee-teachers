# frozen_string_literal: true

require "rails_helper"

feature "edit disability disclosure", type: :feature do
  background { given_i_am_authenticated }

  context "when a trainee has not disclosed a disability" do
    background do
      given_a_trainee_exists_with_no_disability_disclosure
      and_i_am_on_the_disability_disclosure_page
    end

    scenario "submitting with no option selected" do
      and_i_submit_the_form
      then_i_see_error_messages
    end

    scenario "choosing to disclose a disability" do
      and_i_choose_to_disclose
      and_i_submit_the_form
      then_i_am_redirected_to_the_disabilities_page
    end

    scenario "choosing not to disclose a disability" do
      and_i_choose_not_to_disclose
      and_i_submit_the_form
      and_confirm_my_details
      then_i_am_redirected_to_the_review_draft_page
    end
  end

  context "when a trainee has already disclosed a disability" do
    background do
      given_a_trainee_exists_with_a_disability
      and_i_am_on_the_disability_disclosure_page
    end

    scenario "choosing not to disclose a disability" do
      and_i_choose_not_to_disclose
      and_i_submit_the_form
      and_i_should_not_see_any_disabilities_listed
    end
  end

private

  def given_a_trainee_exists_with_no_disability_disclosure
    given_a_trainee_exists(:diversity_disclosed, disability_disclosure: nil)
  end

  def given_a_trainee_exists_with_a_disability
    given_a_trainee_exists(:diversity_disclosed, disability_disclosure: :disabled, disabilities: [create(:disability)])
  end

  def and_i_am_on_the_disability_disclosure_page
    disability_disclosure_page.load(id: trainee.slug)
  end

  def and_i_choose_to_disclose
    disability_disclosure_page.disabled.choose
  end

  def and_i_choose_not_to_disclose
    disability_disclosure_page.public_send(%w[disability_not_provided no_disability].sample).choose
  end

  def and_i_submit_the_form
    disability_disclosure_page.submit_button.click
  end

  def and_confirm_my_details
    diversities_confirm_page.submit_button.click
  end

  def then_i_am_redirected_to_the_disabilities_page
    expect(disabilities_page).to be_displayed(id: trainee.slug)
  end

  def and_i_should_not_see_any_disabilities_listed
    expect(disabilities_page).to_not have_content("Disabilities shared:")
  end

  def then_i_see_error_messages
    expect(disabilities_page).to have_content(
      I18n.t("activemodel.errors.models.diversities/disability_disclosure_form.attributes.disability_disclosure.blank"),
    )
  end
end
