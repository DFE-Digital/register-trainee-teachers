# frozen_string_literal: true

require "rails_helper"

feature "edit ethnic group", type: :feature do
  background  do
    given_i_am_authenticated
    given_a_trainee_exists(:diversity_disclosed, :disability_not_provided)
  end

  scenario "edit with valid parameters" do
    and_i_am_on_the_diversity_ethnic_group_page
    and_i_choose_the_asian_option
    and_i_submit_the_form
    then_i_am_redirected_to_the_ethnic_background_page
    and_the_diversity_ethnic_group_is_updated_with_asian
  end

  context "trainee with no defined ethnic group" do
    background do
      given_i_visited_the_diversities_confirm_page_page
      and_i_am_on_the_diversity_ethnic_group_page
    end

    scenario "edit with valid parameters" do
      and_i_choose_the_asian_option
      and_i_submit_the_form
      then_i_am_redirected_to_the_ethnic_background_page
      and_the_diversity_ethnic_group_is_updated_with_asian
    end

    scenario "edit with invalid parameters" do
      and_i_submit_the_form
      then_i_see_error_messages
    end

    scenario "choosing not to provide ethnic group" do
      and_i_choose_the_not_provided_option
      and_i_submit_the_form
      then_i_am_redirected_to_the_diversities_confirm_page_page
      and_the_diversity_ethnic_group_is_updated_with_not_provided
    end
  end

  scenario "choosing not to provide ethnic group" do
    given_i_visited_the_diversities_confirm_page_page
    and_i_am_on_the_diversity_ethnic_group_page
    and_i_choose_the_not_provided_option
    and_i_submit_the_form
    then_i_am_redirected_to_the_diversities_confirm_page_page
    and_the_diversity_ethnic_group_is_updated_with_not_provided
  end

  def and_i_choose_the_asian_option
    and_i_choose(Diversities::ETHNIC_GROUP_ENUMS[:asian])
  end

  def and_i_choose_the_not_provided_option
    and_i_choose(Diversities::ETHNIC_GROUP_ENUMS[:not_provided])
  end

  def and_the_diversity_ethnic_group_is_updated_with_asian
    expect(trainee.reload.ethnic_group).to eq(Diversities::ETHNIC_GROUP_ENUMS[:asian])
  end

  def and_the_diversity_ethnic_group_is_updated_with_not_provided
    expect(trainee.reload.ethnic_group).to eq(Diversities::ETHNIC_GROUP_ENUMS[:not_provided])
  end

  def and_i_am_on_the_diversity_ethnic_group_page
    ethnic_group_page.load(id: trainee.slug)
  end

  def and_i_submit_the_form
    ethnic_group_page.submit_button.click
  end

  def then_i_am_redirected_to_the_ethnic_background_page
    expect(ethnic_background_page).to be_displayed(id: trainee.slug)
  end

  def then_i_am_redirected_to_the_disability_disclosure_page
    expect(disability_disclosure_page).to be_displayed(id: trainee.slug)
  end

  def and_the_previous_ethnic_background_is_cleared
    expect(trainee.reload.ethnic_background).to be_nil
  end

  def and_i_see_ethnic_background_options_for_the_selected_group
    Diversities::BACKGROUNDS[Diversities::ETHNIC_GROUP_ENUMS[:asian]].each do |ethnic_background|
      expect(ethnic_background_page.find(ethnic_background_option(ethnic_background))).to be_visible
    end
  end

  def then_i_see_error_messages
    expect(ethnic_background_page).to have_content(
      I18n.t("activemodel.errors.models.diversities/ethnic_group_form.attributes.ethnic_group.blank"),
    )
  end

private

  def ethnic_background_option(ethnic_background)
    formatted_id = ethnic_background.parameterize
    "#diversities-ethnic-background-form-ethnic-background-#{formatted_id}-field"
  end
end
