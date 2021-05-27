# frozen_string_literal: true

require "rails_helper"

feature "edit diversity disclosure", type: :feature do
  background do
    given_i_am_authenticated
    given_a_trainee_exists(diversity_disclosure: nil)
    given_i_am_on_the_review_draft_page
    and_i_am_on_the_diversity_disclosure_page
  end

  scenario "choosing to disclose" do
    and_i_choose_to_disclose
    and_i_submit_the_form
    then_i_am_redirected_to_the_ethnic_group_page
    and_the_diversity_disclosure_is_updated
  end

  scenario "choosing not to disclose" do
    and_i_choose_not_to_disclose
    and_i_submit_the_form
    and_confirm_my_details
    then_i_am_redirected_to_the_review_draft_page
    and_the_diversity_disclosure_is_updated
  end

  scenario "edit with invalid parameters" do
    and_i_submit_the_form
    then_i_see_error_messages
  end

  def and_i_am_on_the_diversity_disclosure_page
    diversity_disclosure_page.load(id: trainee.slug)
  end

  def and_i_choose_to_disclose
    diversity_disclosure_page.yes.choose
  end

  def and_i_choose_not_to_disclose
    diversity_disclosure_page.no.choose
  end

  def and_i_submit_the_form
    diversity_disclosure_page.submit_button.click
  end

  def and_confirm_my_details
    expect(diversities_confirm_page).to be_displayed(id: trainee.slug)
    diversities_confirm_page.submit_button.click
  end

  def then_i_am_redirected_to_the_ethnic_group_page
    expect(ethnic_group_page).to be_displayed(id: trainee.slug)
  end

  def and_the_diversity_disclosure_is_updated
    expect(trainee.reload.diversity_disclosure).to be_truthy
  end

  def then_i_see_error_messages
    content = I18n.t("activemodel.errors.models.diversities/disclosure_form.attributes.diversity_disclosure.blank")
    expect(ethnic_group_page).to have_content(content)
  end
end
