# frozen_string_literal: true

require "spec_helper_smoke"

describe "User login spec" do
  before do
    skip "DfE sign-in not enabled" unless Settings.features.sign_in_method == "dfe-sign-in"
  end

  scenario "signing in successfully", js: true do
    visit_sign_in_page
    fill_in_login_credentials
    submit_login_form
    verify_successful_login
    sign_out
  end

private

  def visit_sign_in_page
    visit "#{url_with_basic_auth}/sign-in"
    click_button "Sign in using DfE Sign-in"
  end

  def fill_in_login_credentials
    fill_in "username", with: Settings.smoke_test&.username
    fill_in "password", with: Settings.smoke_test&.password
  end

  def submit_login_form
    click_button "Sign in"
  end

  def verify_successful_login
    expect(page).to have_content("Sign out")
  end

  def sign_out
    click_link "Sign out"
    expect(page).to have_content("Sign in")
  end

  def url_with_basic_auth
    uri = URI.parse(Settings.base_url)
    uri.user = Settings.basic_auth&.username
    uri.password = Settings.basic_auth&.password
    uri.to_s
  end
end
