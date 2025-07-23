# frozen_string_literal: true

require "rails_helper"

describe "A user authenticates via Email Sign-in" do
  let!(:user) { create(:user, :with_otp_secret) }
  let!(:salt) { ROTP::Base32.random(16) }
  let!(:otp)  { ROTP::TOTP.new(user.otp_secret + salt, issuer: "Register") }
  let(:code) { "123456" }
  let(:incorrect_code) { "654321" }
  let(:mailer) { double(:mailer, deliver_later: true) }

  before do
    # rather than digging and finding the session[:otp_salt] we set it here
    allow(ROTP::Base32).to receive(:random).with(16).and_return(salt)

    # this means we can generate the OTP code in the test
    allow(ROTP::TOTP).to receive(:new).with(user.otp_secret + salt, issuer: "Register").and_return(otp)
    allow(otp).to receive(:now).and_return(code)
    allow(otp).to receive(:verify).with(incorrect_code, drift_behind: 600).and_return(nil)
    allow(otp).to receive(:verify).with(code, drift_behind: 600).and_return(Time.zone.now)

    # and make sure the mailer is called with the correct OTP code
    allow(OtpMailer).to receive(:generate).with(
      name: user.name,
      email: user.email,
      code: code,
    ).and_return(mailer)
  end

  context "as a non-system admin" do
    scenario "signing in successfully", feature_sign_in_method: "otp" do
      given_i_am_registered_as_a_user
      and_submit_my_email
      and_enter_my_otp
      then_i_am_redirected_to_the_root_path
      and_i_should_see_the_link_to_sign_out
      and_i_should_not_see_the_link_to_the_support_interface
    end

    scenario "attempting to signin with an invalid code", feature_sign_in_method: "otp" do
      given_i_am_registered_as_a_user
      and_submit_my_email
      and_enter_an_incorrect_otp
      then_i_am_redirected_to_the_otp_form
    end
  end

  context "as a system admin" do
    let!(:user) { create(:user, :system_admin, :with_otp_secret) }

    scenario "signing in successfully", feature_sign_in_method: "otp" do
      given_i_am_registered_as_a_user
      and_submit_my_email
      and_enter_my_otp
      then_i_am_redirected_to_the_root_path
      and_i_should_see_the_link_to_the_support_interface
      and_i_can_access_the_support_interface
    end
  end

private

  def given_i_am_registered_as_a_user
    visit "/sign-in"
    sign_in_page.otp_sign_in_button.click
  end

  def and_submit_my_email
    otp_page.email.fill_in(with: user.email)
    otp_page.submit.click
  end

  def and_enter_my_otp
    otp_verification_page.code.fill_in(with: code)
    otp_verification_page.submit.click
  end

  def and_enter_an_incorrect_otp
    otp_verification_page.code.fill_in(with: incorrect_code)
    otp_verification_page.submit.click
  end

  def then_i_am_redirected_to_the_root_path
    expect(page).to have_current_path("/")
  end

  def and_i_should_see_the_link_to_sign_out
    expect(page).to have_content("Sign out")
  end

  def and_i_should_see_the_link_to_the_support_interface
    expect(page).to have_content("Support")
  end

  def and_i_should_not_see_the_link_to_the_support_interface
    expect(page).not_to have_content("Support")
  end

  def and_i_can_access_the_support_interface
    click_on("Support")
  end

  def then_i_am_redirected_to_the_otp_form
    expect(page).to have_current_path(otp_verifications_path)
    expect(page).to have_content("The code is incorrect or has expired")
  end
end
