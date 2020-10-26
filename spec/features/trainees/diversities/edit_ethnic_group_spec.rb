require "rails_helper"

feature "edit ethnic group", type: :feature do
  scenario "edit with valid parameters" do
    given_a_trainee_exists
    when_i_visit_the_diversity_ethnic_group_page
    and_i_enter_valid_parameters
    and_i_submit_the_form
    then_i_am_redirected_to_the_summary_page
    and_the_diversity_ethnic_group_is_updated
  end

  scenario "edit with invalid parameters" do
    given_a_trainee_exists
    when_i_visit_the_diversity_ethnic_group_page
    and_i_submit_the_form
    then_i_see_error_messages
  end

  def given_a_trainee_exists
    @trainee = create(:trainee, ethnic_group: nil)
  end

  def when_i_visit_the_diversity_ethnic_group_page
    @ethnic_group_page ||= PageObjects::Trainees::Diversities::EthnicGroup.new
    @ethnic_group_page.load(id: @trainee.id)
  end

  def and_i_enter_valid_parameters
    @ethnic_group_page.asian.choose
  end

  def and_i_submit_the_form
    @ethnic_group_page.submit_button.click
  end

  def then_i_am_redirected_to_the_summary_page
    @summary_page ||= PageObjects::Trainees::Summary.new
    expect(@summary_page).to be_displayed(id: @trainee.id)
  end

  def and_the_diversity_ethnic_group_is_updated
    when_i_visit_the_diversity_ethnic_group_page
    expect(@ethnic_group_page.asian).to be_checked
  end

  def then_i_see_error_messages
    expect(page).to have_content(
      I18n.t("activemodel.errors.models.diversities/ethnic_group.attributes.ethnic_group.blank"),
    )
  end
end
