require "rails_helper"

feature "edit diversity disclosure", type: :feature do
  scenario "edit with valid parameters" do
    given_a_trainee_exists
    when_i_visit_the_diversity_disclosure_page
    and_i_enter_valid_parameters
    and_i_submit_the_form
    then_i_am_redirected_to_the_summary_page
    and_the_diversity_disclosure_is_updated
  end

  scenario "edit with invalid parameters" do
    given_a_trainee_exists
    when_i_visit_the_diversity_disclosure_page
    and_i_submit_the_form
    then_i_see_error_messages
  end

  def given_a_trainee_exists
    @trainee = create(:trainee, diversity_disclosure: nil)
  end

  def when_i_visit_the_diversity_disclosure_page
    @disclosure_page ||= PageObjects::Trainees::Diversities::Disclosure.new
    @disclosure_page.load(id: @trainee.id)
  end

  def and_i_enter_valid_parameters
    @disclosure_page.yes.choose
  end

  def and_i_submit_the_form
    @disclosure_page.submit_button.click
  end

  def then_i_am_redirected_to_the_summary_page
    @summary_page ||= PageObjects::Trainees::Summary.new
    expect(@summary_page).to be_displayed(id: @trainee.id)
  end

  def and_the_diversity_disclosure_is_updated
    when_i_visit_the_diversity_disclosure_page
    expect(@disclosure_page.yes).to be_checked
  end

  def then_i_see_error_messages
    expect(page).to have_content(
      I18n.t("activemodel.errors.models.diversities/disclosure.attributes.diversity_disclosure.blank"),
    )
  end
end
