# frozen_string_literal: true

require "rails_helper"

describe "A user authenticates via Email Sign-in" do
  before do
    # This forces verification (which is tested in otp_verifications_form_spec) to return true
    allow_any_instance_of(OtpVerificationsForm).to receive(:code_is_correct?).and_return(nil)
  end

  scenario "signing in successfully", feature_use_otp_sign_in: true do
    given_i_am_registered_as_a_user
    and_submit_my_email
    and_enter_my_otp
    then_i_am_redirected_to_the_root_path
    and_i_should_see_the_link_to_sign_out
  end

private

  def user
    @user ||= create(:user)
  end

  def given_i_am_registered_as_a_user
    user
    visit "/sign-in"
    sign_in_page.otp_sign_in_button.click
  end

  def and_submit_my_email
    otp_page.email.fill_in(with: user.email)
    otp_page.submit.click
  end

  def and_enter_my_otp
    otp_verification_page.code.fill_in(with: "1234")
    otp_verification_page.submit.click
  end

  def then_i_am_redirected_to_the_root_path
    expect(page).to have_current_path("/")
  end

  def and_i_should_see_the_link_to_sign_out
    expect(page).to have_content("Sign out")
  end
end
