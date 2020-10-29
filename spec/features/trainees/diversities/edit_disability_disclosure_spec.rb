require "rails_helper"

feature "edit disability disclosure", type: :feature do
  scenario "disclosing a disability" do
    given_a_trainee_exists
    when_i_visit_the_disability_disclosure_page
    and_i_choose_to_disclose
    and_i_submit_the_form
    then_i_am_redirected_to_the_summary_page
    and_the_disability_disclosure_is_updated
  end

  scenario "submitting with no option selected" do
    given_a_trainee_exists
    when_i_visit_the_disability_disclosure_page
    and_i_submit_the_form
    then_i_see_error_messages
  end

  scenario "returning to the correct previous step" do
    given_a_trainee_without_an_ethnic_group_exists
    when_i_visit_the_diversity_ethnic_group_page
    and_i_submit_the_ethnic_group_form
    and_i_click_back
    then_i_should_return_to_ethnic_group_page
  end

  def given_a_trainee_exists
    @trainee = create(:trainee, disability_disclosure: nil)
  end

  def given_a_trainee_without_an_ethnic_group_exists
    @trainee = create(
      :trainee,
      ethnic_group: Diversities::ETHNIC_GROUP_ENUMS[:not_provided],
    )
  end

  def when_i_visit_the_disability_disclosure_page
    @disability_disclosure_page ||= PageObjects::Trainees::Diversities::DisabilityDisclosure.new
    @disability_disclosure_page.load(id: @trainee.id)
  end

  def and_i_choose_to_disclose
    @disability_disclosure_page.disabled.choose
  end

  def and_i_submit_the_form
    @disability_disclosure_page.submit_button.click
  end

  def then_i_am_redirected_to_the_summary_page
    @summary_page ||= PageObjects::Trainees::Summary.new
    expect(@summary_page).to be_displayed(id: @trainee.id)
  end

  def and_the_disability_disclosure_is_updated
    expect(@trainee.reload.disability_disclosure).to be_truthy
  end

  def when_i_visit_the_diversity_ethnic_group_page
    @ethnic_group_page ||= PageObjects::Trainees::Diversities::EthnicGroup.new
    @ethnic_group_page.load(id: @trainee.id)
  end

  def and_i_submit_the_ethnic_group_form
    @ethnic_group_page.submit_button.click
  end

  def and_i_click_back
    expect(page.current_path).to eq(edit_trainee_diversity_disability_disclosure_path(@trainee))
    page.find(".govuk-back-link").click
  end

  def then_i_should_return_to_ethnic_group_page
    expect(@ethnic_group_page).to be_displayed(id: @trainee.id)
  end

  def then_i_see_error_messages
    expect(page).to have_content(
      I18n.t("activemodel.errors.models.diversities/disability_disclosure.attributes.disability_disclosure.blank"),
    )
  end
end
