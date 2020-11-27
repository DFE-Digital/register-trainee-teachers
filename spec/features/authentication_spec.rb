# frozen_string_literal: true

require "rails_helper"
describe "A user authenticates via DfE Sign-in" do
  scenario "signing in successfully" do
    given_i_am_registered_as_a_user
    and_i_have_a_dfe_sign_in_account

    when_i_visit_the_trainee_page
    then_i_am_redirected_to_the_sign_path
    and_i_sign_in_via_dfe_sign_in

    then_i_am_redirected_to_the_trainee_path
    and_i_should_see_the_link_to_sign_out
    and_my_details_are_refreshed

    when_i_signed_in_more_than_2_hours_ago
    then_i_should_see_the_sign_in_page_again
  end

private

  def user
    @user ||= create(:user)
  end

  def given_i_am_registered_as_a_user
    user
  end

  def user_first_name
    "Bob"
  end

  def and_i_have_a_dfe_sign_in_account
    user.first_name = user_first_name
    user_exists_in_dfe_sign_in(user: user)
  end

  def when_i_visit_the_trainee_page
    trainee_page = PageObjects::Trainees::Index.new
    trainee_page.load
  end

  def then_i_am_redirected_to_the_sign_path
    expect(page.current_path).to eq("/sign-in")
  end

  def and_i_sign_in_via_dfe_sign_in
    visit_sign_in_page
  end

  def then_i_am_redirected_to_the_trainee_path
    expect(page.current_path).to eq("/trainees")
  end

  def and_i_should_see_the_link_to_sign_out
    expect(page).to have_content("Sign out")
  end

  def and_my_details_are_refreshed
    expect(user.reload.last_signed_in_at).not_to be_nil
    expect(user.reload.first_name).to eq(user_first_name)
  end

  def then_i_should_see_the_sign_in_page_again
    expect(page).to have_button("Sign in using DfE Sign-in")
  end

  def when_i_signed_in_more_than_2_hours_ago
    Timecop.travel(Time.zone.now + 2.hours + 1.second) do
      expect(page.current_path).to eq("/trainees")

      trainee_page = PageObjects::Trainees::Index.new
      trainee_page.load
    end
  end
end
