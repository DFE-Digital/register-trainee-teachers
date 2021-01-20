# frozen_string_literal: true

require "rails_helper"

feature "edit diversity disclosure", type: :feature do
  background do
    given_i_am_authenticated
    given_a_trainee_exists(diversity_disclosure: nil)
    when_i_visit_the_diversity_disclosure_page
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
    then_i_am_redirected_to_the_record_page
    and_the_diversity_disclosure_is_updated
  end

  scenario "edit with invalid parameters" do
    and_i_submit_the_form
    then_i_see_error_messages
  end

  def when_i_visit_the_diversity_disclosure_page
    @disclosure_page ||= PageObjects::Trainees::Diversities::Disclosure.new
    @disclosure_page.load(id: trainee.id)
  end

  def and_i_choose_to_disclose
    @disclosure_page.yes.choose
  end

  def and_i_choose_not_to_disclose
    @disclosure_page.no.choose
  end

  def and_i_submit_the_form
    @disclosure_page.submit_button.click
  end

  def and_confirm_my_details
    @confirm_page ||= PageObjects::Trainees::Diversities::ConfirmDetails.new
    expect(@confirm_page).to be_displayed(id: trainee.id, section: "information-disclosed")
    @confirm_page.submit_button.click
  end

  def then_i_am_redirected_to_the_ethnic_group_page
    @ethnic_group ||= PageObjects::Trainees::Diversities::EthnicGroup.new
    expect(@ethnic_group).to be_displayed(id: trainee.id)
  end

  def and_the_diversity_disclosure_is_updated
    expect(trainee.reload.diversity_disclosure).to be_truthy
  end

  def then_i_see_error_messages
    expect(page).to have_content(I18n.t("activemodel.errors.models.diversities/disclosure_form.attributes.diversity_disclosure.blank"))
  end
end
