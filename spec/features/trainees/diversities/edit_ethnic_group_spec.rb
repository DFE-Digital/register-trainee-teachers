require "rails_helper"

feature "edit ethnic group", type: :feature do
  scenario "edit with valid parameters" do
    given_a_trainee_exists
    when_i_visit_the_diversity_ethnic_group_page
    and_i_choose(Diversities::ETHNIC_GROUP_ENUMS[:asian])
    and_i_submit_the_form
    then_i_am_redirected_to_the_ethnic_background_page
    and_the_diversity_ethnic_group_is_updated_with(Diversities::ETHNIC_GROUP_ENUMS[:asian])
  end

  scenario "edit with invalid parameters" do
    given_a_trainee_exists
    when_i_visit_the_diversity_ethnic_group_page
    and_i_submit_the_form
    then_i_see_error_messages
  end

  scenario "updating the ethnic group clears the previous ethnic background" do
    given_a_trainee_with_a_background_exists
    when_i_visit_the_diversity_ethnic_group_page
    and_i_choose(Diversities::ETHNIC_GROUP_ENUMS[:asian])
    and_i_submit_the_form
    then_i_am_redirected_to_the_ethnic_background_page
    and_the_diversity_ethnic_group_is_updated_with(Diversities::ETHNIC_GROUP_ENUMS[:asian])
    and_the_previous_ethnic_background_is_cleared
    and_i_see_ethnic_background_options_for_the_selected_group
  end

  scenario "choosing not to provide ethnic group" do
    given_a_trainee_exists
    when_i_visit_the_diversity_ethnic_group_page
    and_i_choose(Diversities::ETHNIC_GROUP_ENUMS[:not_provided])
    and_i_submit_the_form
    then_i_am_redirected_to_the_disability_disclosure_page
    and_the_diversity_ethnic_group_is_updated_with(Diversities::ETHNIC_GROUP_ENUMS[:not_provided])
  end

  def given_a_trainee_exists
    @trainee = create(:trainee, ethnic_group: nil)
  end

  def given_a_trainee_with_a_background_exists
    @trainee = create(
      :trainee,
      ethnic_group: Diversities::ETHNIC_GROUP_ENUMS[:mixed],
      ethnic_background: Diversities::BACKGROUNDS[Diversities::ETHNIC_GROUP_ENUMS[:mixed]].sample,
    )
  end

  def when_i_visit_the_diversity_ethnic_group_page
    @ethnic_group_page ||= PageObjects::Trainees::Diversities::EthnicGroup.new
    @ethnic_group_page.load(id: @trainee.id)
  end

  def and_i_choose(option)
    @ethnic_group_page.find(
      "#diversities-ethnic-group-ethnic-group-#{option.dasherize}-field",
    ).choose
  end

  def and_i_submit_the_form
    @ethnic_group_page.submit_button.click
  end

  def then_i_am_redirected_to_the_ethnic_background_page
    @ethnic_background_page ||= PageObjects::Trainees::Diversities::EthnicBackground.new
    expect(@ethnic_background_page).to be_displayed(id: @trainee.id)
  end

  def then_i_am_redirected_to_the_disability_disclosure_page
    @disability_disclosure_page ||= PageObjects::Trainees::Diversities::DisabilityDisclosure.new
    expect(@disability_disclosure_page).to be_displayed(id: @trainee.id)
  end

  def and_the_diversity_ethnic_group_is_updated_with(selected_group)
    expect(@trainee.reload.ethnic_group).to eq(selected_group)
  end

  def and_the_previous_ethnic_background_is_cleared
    expect(@trainee.reload.ethnic_background).to be_nil
  end

  def and_i_see_ethnic_background_options_for_the_selected_group
    Diversities::BACKGROUNDS[Diversities::ETHNIC_GROUP_ENUMS[:asian]].each do |ethnic_background|
      expect(page.find(ethnic_background_option(ethnic_background))).to be_visible
    end
  end

  def then_i_see_error_messages
    expect(page).to have_content(
      I18n.t("activemodel.errors.models.diversities/ethnic_group.attributes.ethnic_group.blank"),
    )
  end

private

  def ethnic_background_option(ethnic_background)
    formatted_id = ethnic_background.parameterize
    "#diversities-ethnic-background-ethnic-background-#{formatted_id}-field"
  end
end
