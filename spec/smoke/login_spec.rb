# frozen_string_literal: true

require "spec_helper_smoke"

# To successfully test this locally you will need to add to your .env file:
#
# SMOKE_TEST_USERNAME
# SMOKE_TEST_PASSWORD
# BASIC_AUTH_USERNAME
# BASIC_AUTH_PASSWORD
#
# you can get the credentials from another Dave G, or another dev
#
# When running, pass in the remote environment name, for example:
#
# RAILS_ENV=production bundle exec rspec spec/smoke/login_spec.rb
#
# The ENV variable are passed eventually to the `.github/actions/smoke-test/action.yml` action
# via either the `.github/workflows/deploy.yml` or `.github/workflows/build-and-deploy.yml` workflows

describe "User login spec" do
  before do
    skip "DfE sign-in not enabled" if Settings.features.sign_in_method != "dfe-sign-in"
  end

  scenario "signing in successfully", js: true do
    visit_sign_in_page
    if Settings.environment.name == "staging"
      login_with_username
      login_with_password
    else
      # NOTE: This can bew removed once DSI has swiched over their login flow
      fill_in "username", with: ENV.fetch("SMOKE_TEST_USERNAME", nil)
      fill_in "password", with: ENV.fetch("SMOKE_TEST_PASSWORD", nil)
      find_button("Sign in").click
    end
    verify_successful_login
    sign_out
  end

private

  def visit_sign_in_page
    visit "#{url_with_basic_auth}/sign-in"
    find_button("Sign in using DfE Sign-in").click
  end

  def login_with_username
    fill_in "username", with: ENV.fetch("SMOKE_TEST_USERNAME", nil)
    find_button("Continue").click
  end

  def login_with_password
    fill_in "password", with: ENV.fetch("SMOKE_TEST_PASSWORD", nil)
    find_button("Sign in").click
  end

  def verify_successful_login
    expect(page).to have_content("Sign out")
  end

  def sign_out
    find_link("Sign out").click
    expect(page).to have_content("Sign in")
  end

  def url_with_basic_auth
    uri = URI.parse(Settings.base_url)

    return uri.to_s unless Settings.features.basic_auth

    uri.user = ENV.fetch("BASIC_AUTH_USERNAME", nil)
    uri.password = ENV.fetch("BASIC_AUTH_PASSWORD", nil)
    uri.to_s
  end
end
