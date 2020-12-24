# frozen_string_literal: true

require "rails_helper"

feature "edit ethnic background", type: :feature do
  background do
    given_i_am_authenticated
  end

  context "selecting a background" do
    scenario "saves the selection successfully" do
      given_a_trainee_exists
      when_i_visit_the_diversity_ethnic_background_page
      and_i_choose_a_background(Diversities::BANGLADESHI.downcase)
      and_i_submit_the_form
      then_i_am_redirected_to_the_disability_disclosure_page
      and_the_diversity_ethnic_background_is_updated_with(Diversities::BANGLADESHI)
    end

    scenario "clears out additional background value if another is selected" do
      given_a_trainee_exists(Diversities::ETHNIC_GROUP_ENUMS[:other])
      with_an_additional_background_provided
      when_i_visit_the_diversity_ethnic_background_page
      and_i_choose_a_background(Diversities::ARAB.downcase)
      and_i_submit_the_form
      then_i_am_redirected_to_the_disability_disclosure_page
      and_the_diversity_ethnic_background_is_updated_with(Diversities::ARAB)
      and_the_additional_background_is_cleared
    end
  end

  context "validations" do
    scenario "displays error message with no values provided" do
      given_a_trainee_exists
      when_i_visit_the_diversity_ethnic_background_page
      and_i_submit_the_form
      then_i_see_error_messages
    end
  end

  def given_a_trainee_exists(group = Diversities::ETHNIC_GROUP_ENUMS[:asian])
    @trainee = create(:trainee, ethnic_group: group, provider: current_user.provider)
  end

  def with_an_additional_background_provided
    @trainee.ethnic_background = Diversities::NOT_PROVIDED
    @trainee.additional_ethnic_background = "some background"
  end

  def when_i_visit_the_diversity_ethnic_background_page
    @ethnic_background_page ||= PageObjects::Trainees::Diversities::EthnicBackground.new
    @ethnic_background_page.load(id: @trainee.id)
  end

  def and_i_choose_a_background(background)
    @ethnic_background_page.public_send(background).choose
  end

  def and_i_submit_the_form
    @ethnic_background_page.submit_button.click
  end

  def then_i_am_redirected_to_the_disability_disclosure_page
    @disability_disclosure_page ||= PageObjects::Trainees::Diversities::DisabilityDisclosure.new
    expect(@disability_disclosure_page).to be_displayed(id: trainee.id)
  end

  def and_the_diversity_ethnic_background_is_updated_with(background)
    expect(trainee.reload.ethnic_background).to eq(background)
  end

  def and_the_additional_background_is_cleared
    expect(trainee.reload.additional_ethnic_background).to be_nil
  end

  def then_i_see_error_messages
    expect(page).to have_content(
      I18n.t("activemodel.errors.models.diversities/ethnic_background_form.attributes.ethnic_background.blank"),
    )
  end
end
