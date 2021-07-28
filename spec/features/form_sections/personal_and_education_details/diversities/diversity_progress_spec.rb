# frozen_string_literal: true

require "rails_helper"

feature "completing the diversity section", type: :feature do
  background do
    given_i_am_authenticated
    given_a_trainee_exists(diversity_disclosure: nil, ethnic_group: nil, disability_disclosure: nil)
  end

  context "progress tracking" do
    scenario "renders a 'incomplete' status when diversity details are not provided" do
      given_i_am_on_the_review_draft_page
      then_the_diversity_section_should_be(incomplete)
    end

    scenario "renders an 'in progress' status when diversity information partially provided" do
      given_valid_diversity_information
      when_i_visit_the_diversity_confirmation_page
      and_unconfirm_my_details
      then_the_diversity_section_should_be(in_progress)
    end

    scenario "renders a completed status when valid diversity information provided" do
      given_valid_diversity_information
      given_i_am_on_the_review_draft_page
      then_the_diversity_section_should_be(completed)
    end
  end

  context "updating a section" do
    scenario "returns back to confirm page after successfully updating" do
      given_valid_diversity_information
      when_i_visit_the_diversity_confirmation_page
      and_i_edit_my_ethnic_group_details
      then_i_am_redirected_to_the_confirm_page
    end
  end

private

  def then_the_diversity_section_should_be(status)
    expect(review_draft_page.diversity_section.status.text).to eq(status)
  end

  def when_i_visit_the_diversity_confirmation_page
    diversities_confirm_page.load(id: @trainee.slug)
  end

  def and_i_edit_my_ethnic_group_details
    diversities_confirm_page.edit_link_for(:ethnicity).click
    and_i_choose(Diversities::ETHNIC_GROUP_ENUMS[:asian])
    ethnic_group_page.submit_button.click
    and_i_choose_a_background(Diversities::BANGLADESHI.downcase)
    ethnic_background_page.submit_button.click
  end

  def then_i_am_redirected_to_the_confirm_page
    expect(diversities_confirm_page).to be_displayed(id: @trainee.slug)
  end

  def and_unconfirm_my_details
    diversities_confirm_page.confirm.uncheck
    diversities_confirm_page.submit_button.click
  end
end
