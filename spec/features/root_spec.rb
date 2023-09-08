# frozen_string_literal: true

require "rails_helper"

feature "root" do
  scenario "navigate to start" do
    given_i_am_on_the_start_page
    then_i_should_see_the_service_name
    and_i_should_see_the_phase_banner
  end

  scenario "navigate to sign in" do
    given_i_am_on_the_start_page
    when_i_click_on_sign_in
    then_the_sign_page_is_displayed
  end

  scenario "navigate to request an account" do
    given_i_am_on_the_start_page
    when_i_click_on_request_an_account
    then_the_request_an_account_page_is_displayed
  end

private

  def given_i_am_on_the_start_page
    start_page.load
  end

  def when_i_click_on_sign_in
    start_page.sign_in.click
  end

  def then_i_should_see_the_service_name
    expect(start_page.page_heading).to have_text(t("page_headings.start_page"))
    expect(start_page).to have_title("Register trainee teachers - GOV.UK")
  end

  def and_i_should_see_the_phase_banner
    expect(start_page.phase_banner).to have_text("Beta")
  end

  def then_the_sign_page_is_displayed
    sign_in_page = PageObjects::SignIn.new
    expect(sign_in_page).to be_displayed
  end

  def when_i_click_on_request_an_account
    start_page.request_an_account.click
  end

  def then_the_request_an_account_page_is_displayed
    expect(request_an_account_page).to be_displayed
    expect(request_an_account_page).to have_text("Request an account")
  end
end
