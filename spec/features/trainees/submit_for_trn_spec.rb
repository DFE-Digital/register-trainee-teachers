require "rails_helper"

feature "submit for TRN" do
  scenario "a valid trainee" do
    given_a_valid_trainee_exists
    when_i_am_viewing_the_summary_page
    and_i_click_the_submit_for_trn_button
    then_i_am_redirected_to_the_success_page
  end

  def given_a_valid_trainee_exists
    trainee
  end

  def when_i_am_viewing_the_summary_page
    summary_page.load(id: trainee.id)
  end

  def and_i_click_the_submit_for_trn_button
    summary_page.submit_for_trn_button.click
  end

  def then_i_am_redirected_to_the_success_page
    expect(trn_success_page).to be_displayed(id: trainee.id)
  end

  def summary_page
    @summary_page ||= PageObjects::Trainees::Summary.new
  end

  def trn_success_page
    @trn_success_page ||= PageObjects::Trainees::TrnSuccess.new
  end

  def trainee
    @trainee ||= create(:trainee)
  end
end
