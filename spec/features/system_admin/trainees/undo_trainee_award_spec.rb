require "rails_helper"

feature "Undoing a trainee award" do
  let(:system_admin) { create(:user, system_admin: true) }

  before do
    given_i_am_authenticated(user: system_admin)
  end

  scenario "can be done by an admin" do
    given_a_trainee_exists(:awarded)
    and_i_am_on_the_trainee_record_page
    and_i_click_remove_qts_award
    then_i_should_see_start_page
    when_i_click_continue
    # then_i_should_see_message_that_award_has_not_been_removed_from_dqt
    # and_the_trainee_should_still_be_awarded
  end

private

  def and_i_click_remove_qts_award
    click_on "Remove QTS award"
  end

  def then_i_should_see_start_page
    expect(page).to have_content("Remove QTS")
  end

  def when_i_click_continue
    click_on "Continue"
  end

  def then_i_should_see_message_that_award_has_not_been_removed_from_dqt
    expect(page).to have_content("The trainee's QTS award has not been removed from DQT")
  end

  def and_the_trainee_should_still_be_awarded
    #TODO:
  end
end
