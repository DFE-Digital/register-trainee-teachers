require "rails_helper"

feature "edit ethnic background", type: :feature do
  scenario "edit with valid parameters" do
    given_a_trainee_exists
    when_i_visit_the_diversity_ethnic_background_page
    and_i_enter_valid_parameters
    and_i_submit_the_form
    then_i_am_redirected_to_the_summary_page
    and_the_diversity_ethnic_background_is_updated
  end

  scenario "edit with invalid parameters" do
    given_a_trainee_exists
    when_i_visit_the_diversity_ethnic_background_page
    and_i_submit_the_form
    then_i_see_error_messages
  end

  def given_a_trainee_exists
    @trainee = create(:trainee, ethnic_group: Diversities::ETHNIC_GROUP_ENUMS[:asian])
  end

  def when_i_visit_the_diversity_ethnic_background_page
    @ethnic_background_page ||= PageObjects::Trainees::Diversities::EthnicBackground.new
    @ethnic_background_page.load(id: @trainee.id)
  end

  def and_i_enter_valid_parameters
    @ethnic_background_page.bangladeshi.choose
  end

  def and_i_submit_the_form
    @ethnic_background_page.submit_button.click
  end

  def then_i_am_redirected_to_the_summary_page
    @summary_page ||= PageObjects::Trainees::Summary.new
    expect(@summary_page).to be_displayed(id: @trainee.id)
  end

  def and_the_diversity_ethnic_background_is_updated
    expect(@trainee.reload.ethnic_background).to eq("Bangladeshi")
  end

  def then_i_see_error_messages
    expect(page).to have_content(
      I18n.t("activemodel.errors.models.diversities/ethnic_background.attributes.ethnic_background.blank"),
    )
  end
end
