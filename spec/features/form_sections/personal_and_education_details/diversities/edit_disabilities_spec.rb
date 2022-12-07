# frozen_string_literal: true

require "rails_helper"

feature "edit disability details" do
  background do
    given_i_am_authenticated
    given_a_disabled_trainee_exists
    given_i_am_on_the_review_draft_page
    and_disabilities_exist_in_the_system
    when_i_visit_the_disability_details_page
  end

  scenario "choosing a disability" do
    and_i_choose_a_disability
    and_i_submit_the_form
    and_confirm_my_details
    then_i_am_redirected_to_the_review_draft_page
    and_the_disability_details_are_updated
  end

  scenario "submitting with no disability chosen" do
    and_i_submit_the_form
    then_i_see_error_messages
  end

  def given_a_disabled_trainee_exists
    given_a_trainee_exists(:diversity_disclosed, :disabled, :with_ethnic_group, :with_ethnic_background)
  end

  def and_disabilities_exist_in_the_system
    @disability = create(:disability, name: "deaf")
  end

  def when_i_visit_the_disability_details_page
    disabilities_page.load(id: trainee.slug)
  end

  def and_i_choose_a_disability
    disabilities_page.disability.check(@disability.name)
  end

  def and_i_submit_the_form
    disabilities_page.submit_button.click
  end

  def and_confirm_my_details
    expect(diversities_confirm_page).to be_displayed(id: trainee.slug)
    diversities_confirm_page.submit_button.click
  end

  def and_the_disability_details_are_updated
    expect(trainee.reload.disabilities).to include(@disability)
  end

  def then_i_see_error_messages
    expect(diversities_confirm_page).to have_content(
      I18n.t(
        "activemodel.errors.models.diversities/disability_detail_form.attributes.disability_ids.empty_disabilities",
      ),
    )
  end
end
