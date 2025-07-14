# frozen_string_literal: true

require "rails_helper"

feature "pages" do
  scenario "navigate to service updates" do
    given_i_am_on_the_start_page
    and_i_click_on_the_news_and_updates_link_in_the_footer
    then_i_should_see_service_updates_page
  end

  scenario "navigate to guidance" do
    given_i_am_on_the_start_page
    and_i_click_on_the_how_to_use_this_service_link_in_the_footer
    then_i_should_see_guidance_page
  end

  scenario "navigate to API documentation" do
    given_i_am_on_the_start_page
    and_i_click_on_the_api_docs_link_in_the_footer
    then_i_should_see_api_docs_page
  end

  scenario "navigate to CSV documentation", feature_bulk_add_trainees: true do
    given_i_am_on_the_start_page
    and_i_click_on_the_csv_docs_link_in_the_footer
    then_i_should_see_csv_docs_page
  end

  scenario "navigate to accessibility statement" do
    given_i_am_on_the_start_page
    and_i_click_on_the_accessibility_link_in_the_footer
    then_i_should_see_the_accessibility_statement
  end

  scenario "navigate to cookies" do
    given_i_am_on_the_start_page
    and_i_click_on_the_cookies_link_in_the_footer
    then_i_should_see_the_cookies_page
  end

  scenario "navigate to privacy policy" do
    given_i_am_on_the_start_page
    and_i_click_on_the_privacy_link_in_the_footer
    then_i_should_see_the_privacy_notice
  end

private

  def given_i_am_on_the_start_page
    start_page.load
  end

  def and_i_click_on_the_accessibility_link_in_the_footer
    start_page.footer.accessibility_link.click
  end

  def and_i_click_on_the_privacy_link_in_the_footer
    start_page.footer.privacy_link.click
  end

  def and_i_click_on_the_csv_docs_link_in_the_footer
    start_page.footer.csv_docs_link.click
  end

  def and_i_click_on_the_api_docs_link_in_the_footer
    start_page.footer.api_docs_link.click
  end

  def and_i_click_on_the_news_and_updates_link_in_the_footer
    start_page.footer.news_and_updates_link.click
  end

  def and_i_click_on_the_how_to_use_this_service_link_in_the_footer
    start_page.footer.how_to_use_this_service_link.click
  end

  def and_i_click_on_the_cookies_link_in_the_footer
    start_page.footer.cookies_link.click
  end

  def then_i_should_see_the_accessibility_statement
    expect(accessibility_page).to be_displayed
    expect(accessibility_page.page_heading).to have_text("Accessibility statement for Register trainee teachers")
  end

  def then_i_should_see_the_privacy_notice
    expect(privacy_notice_page).to be_displayed
    expect(privacy_notice_page.page_heading).to have_text("Register trainee teachers (Register) privacy notice")
  end

  def then_i_should_see_api_docs_page
    expect(api_docs_page).to be_displayed
    expect(api_docs_page.page_heading).to have_text("Register API documentation")
  end

  def then_i_should_see_csv_docs_page
    expect(csv_docs_page).to be_displayed
    expect(csv_docs_page.page_heading).to have_text("How to add trainee information to the bulk add new trainee CSV template")
  end

  def then_i_should_see_reference_data_page
    expect(reference_data_page).to be_displayed
    expect(reference_data_page.page_heading).to have_text("Reference data")
  end

  def then_i_should_see_service_updates_page
    expect(service_updates_page).to be_displayed
    expect(service_updates_page.page_heading).to have_text("News and updates")
  end

  def then_i_should_see_guidance_page
    expect(guidance_page).to be_displayed
    expect(guidance_page.page_heading).to have_text("How to use this service")
  end

  def then_i_should_see_the_cookies_page
    expect(cookies_page).to be_displayed
    expect(cookies_page.page_heading).to have_text("Cookies on Register trainee teachers")
  end
end
