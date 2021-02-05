# frozen_string_literal: true

require "rails_helper"

feature "view pages" do
  scenario "navigate to start" do
    given_i_am_on_the_start_page
    then_i_should_see_the_service_name
    and_i_should_see_the_phase_banner
  end

  scenario "navigate to accessibility statement" do
    given_i_am_on_the_start_page
    and_i_click_on_the_accessibility_link_in_the_footer
    then_i_should_see_the_accessibility_statement
  end

  scenario "navigate to cookies policy" do
    given_i_am_on_the_start_page
    and_i_click_on_the_cookies_link_in_the_footer
    then_i_should_see_the_cookies_policy
  end

  scenario "navigate to privacy policy" do
    given_i_am_on_the_start_page
    and_i_click_on_the_privacy_link_in_the_footer
    then_i_should_see_the_privacy_policy
  end

  scenario "navigate to sign in" do
    given_i_am_on_the_start_page
    when_i_click_on_sign_in
    then_the_start_page_is_displayed
  end

private

  def given_i_am_on_the_start_page
    start_page.load
  end

  def when_i_click_on_sign_in
    start_page.sign_in.click
  end

  def then_the_start_page_is_displayed
    sign_in_page = PageObjects::SignIn.new
    expect(sign_in_page).to be_displayed
  end

  def then_i_should_see_the_service_name
    expect(start_page.page_heading).to have_text(t("page_headings.start_page"))
    expect(start_page).to have_title("Register trainee teachers - GOV.UK")
  end

  def and_i_should_see_the_phase_banner
    expect(start_page.phase_banner).to have_text("Beta")
  end

  def and_i_click_on_the_accessibility_link_in_the_footer
    start_page.footer.accessibility_link.click
  end

  def and_i_click_on_the_cookies_link_in_the_footer
    start_page.footer.cookies_link.click
  end

  def and_i_click_on_the_privacy_link_in_the_footer
    start_page.footer.privacy_link.click
  end

  def then_i_should_see_the_accessibility_statement
    expect(accessibility_page).to be_displayed
    expect(accessibility_page.page_heading).to have_text("Accessibility statement for #{I18n.t('service_name')}")
  end

  def then_i_should_see_the_cookies_policy
    expect(cookies_page).to be_displayed
    expect(cookies_page.page_heading).to have_text("Cookies")
  end

  def then_i_should_see_the_privacy_policy
    expect(privacy_policy_page).to be_displayed
    expect(privacy_policy_page.page_heading).to have_text(t("components.page_titles.pages.privacy_policy"))
  end
end
