# frozen_string_literal: true

require "rails_helper"

feature "edit ethnic group", type: :feature do
  background { given_i_am_authenticated }

  scenario "edit with valid parameters" do
    given_a_trainee_exists
    and_i_am_on_the_diversity_ethnic_group_page
    and_i_choose(Diversities::ETHNIC_GROUP_ENUMS[:asian])
    and_i_submit_the_form
    then_i_am_redirected_to_the_ethnic_background_page
    and_the_diversity_ethnic_group_is_updated_with(Diversities::ETHNIC_GROUP_ENUMS[:asian])
  end

  context "trainee with no defined ethnic group" do
    background do
      given_a_trainee_exists
      given_i_visited_the_diversities_confirm_page_page
      and_i_am_on_the_diversity_ethnic_group_page
    end

    scenario "edit with valid parameters" do
      and_i_choose(Diversities::ETHNIC_GROUP_ENUMS[:asian])
      and_i_submit_the_form
      then_i_am_redirected_to_the_ethnic_background_page
      and_the_diversity_ethnic_group_is_updated_with(Diversities::ETHNIC_GROUP_ENUMS[:asian])
    end

    scenario "edit with invalid parameters" do
      and_i_submit_the_form
      then_i_see_error_messages
    end

    scenario "choosing not to provide ethnic group" do
      and_i_choose(Diversities::ETHNIC_GROUP_ENUMS[:not_provided])
      and_i_submit_the_form
      then_i_am_redirected_to_the_diversities_confirm_page_page
      and_the_diversity_ethnic_group_is_updated_with(Diversities::ETHNIC_GROUP_ENUMS[:not_provided])
    end
  end

  scenario "updating the ethnic group clears the previous ethnic background" do
    given_a_trainee_with_a_background_exists
    and_i_am_on_the_diversity_ethnic_group_page
    and_i_choose(Diversities::ETHNIC_GROUP_ENUMS[:asian])
    and_i_submit_the_form
    then_i_am_redirected_to_the_ethnic_background_page
    and_the_diversity_ethnic_group_is_updated_with(Diversities::ETHNIC_GROUP_ENUMS[:asian])
    and_the_previous_ethnic_background_is_cleared
    and_i_see_ethnic_background_options_for_the_selected_group
  end

  scenario "choosing not to provide ethnic group" do
    given_a_trainee_exists
    given_i_visited_the_diversities_confirm_page_page
    and_i_am_on_the_diversity_ethnic_group_page
    and_i_choose(Diversities::ETHNIC_GROUP_ENUMS[:not_provided])
    and_i_submit_the_form
    then_i_am_redirected_to_the_diversities_confirm_page_page
    and_the_diversity_ethnic_group_is_updated_with(Diversities::ETHNIC_GROUP_ENUMS[:not_provided])
  end

  def given_a_trainee_exists
    @trainee = create(:trainee, ethnic_group: nil, provider: current_user.provider)
  end

  def given_a_trainee_with_a_background_exists
    @trainee = create(
      :trainee,
      ethnic_group: Diversities::ETHNIC_GROUP_ENUMS[:mixed],
      ethnic_background: Diversities::BACKGROUNDS[Diversities::ETHNIC_GROUP_ENUMS[:mixed]].sample,
      provider: current_user.provider,
    )
  end

  def and_i_am_on_the_diversity_ethnic_group_page
    ethnic_group_page.load(id: trainee.slug)
  end

  def and_i_choose(option)
    ethnic_group_page.find(
      "#diversities-ethnic-group-form-ethnic-group-#{option.dasherize}-field",
    ).choose
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

  def and_the_diversity_ethnic_group_is_updated_with(selected_group)
    expect(trainee.reload.ethnic_group).to eq(selected_group)
  end

  def and_the_previous_ethnic_background_is_cleared
    expect(trainee.reload.ethnic_background).to be_nil
  end

  def and_i_see_ethnic_background_options_for_the_selected_group
    Diversities::BACKGROUNDS[Diversities::ETHNIC_GROUP_ENUMS[:asian]].each do |ethnic_background|
      expect(page.find(ethnic_background_option(ethnic_background))).to be_visible
    end
  end

  def then_i_see_error_messages
    expect(page).to have_content(
      I18n.t("activemodel.errors.models.diversities/ethnic_group_form.attributes.ethnic_group.blank"),
    )
  end

private

  def ethnic_background_option(ethnic_background)
    formatted_id = ethnic_background.parameterize
    "#diversities-ethnic-background-form-ethnic-background-#{formatted_id}-field"
  end
end
