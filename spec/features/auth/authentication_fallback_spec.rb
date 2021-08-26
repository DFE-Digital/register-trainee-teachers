# frozen_string_literal: true

require "rails_helper"

RSpec.describe "user authenticates with magic" do
  include DfESignInUserHelper
  include ActiveJob::TestHelper

  scenario "signing in successfully with magic link", feature_use_dfe_sign_in: false, feature_dfe_sign_in_fallback: true do
    given_i_am_registered_as_a_user
    when_i_visit_the_sign_in_page
    then_i_am_redirected_to_the_sign_in_fallback_page

    when_i_provide_my_email_address
    then_i_receive_an_email_with_a_signin_link
    when_i_click_on_the_link_in_my_email
    then_i_am_signed_in

    when_i_sign_out
    then_i_am_not_signed_in

    when_i_click_an_incorrect_sign_in_link
    then_i_see_a_not_found_error
  end

  scenario "sign_in_fallback disabled", feature_dfe_sign_in_fallback: false do
    given_i_am_registered_as_a_user
    when_i_visit_the_sign_in_page
    then_i_see_the_sign_in_page
  end

  def given_i_am_registered_as_a_user
    @email = "support@example.com"
    @user = create(:user, email: @email, dfe_sign_in_uid: "DFE_SIGN_IN_UID", first_name: "Michael")
  end

  def when_i_visit_the_sign_in_page
    sign_in_page.load
  end

  def then_i_am_redirected_to_the_sign_in_fallback_page
    expect(sign_in_fallback_page).to be_displayed
  end

  def then_i_see_the_sign_in_page
    expect(sign_in_page).to be_displayed
  end

  def when_i_provide_my_email_address
    fill_in "Email address", with: "sUpPoRt@example.com "
    perform_enqueued_jobs do
      click_button("Continue")
    end
  end

  def then_i_receive_an_email_with_a_signin_link
    open_email(@email)
    expect(current_email.subject).to have_text(t("authentication.sign_in.email.subject"))
  end

  def when_i_click_on_the_link_in_my_email
    current_email.find_css("a").first.click
  end

  def then_i_am_signed_in
    expect(page).to have_text("Sign out")
  end

  def when_i_sign_out
    click_link("Sign out")
  end

  def then_i_am_not_signed_in
    expect(page).not_to have_text("Trainee records")
  end

  def when_i_click_an_incorrect_sign_in_link
    visit authenticate_with_token_url(token: "NOT_A_REAL_TOKEN")
  end

  def then_i_see_a_not_found_error
    expect(page).to have_text("Page not found")
  end
end
