# frozen_string_literal: true

require "rails_helper"

feature "pages" do
  scenario "navigate to accessibility statement" do
    given_i_am_on_the_start_page
    and_i_click_on_the_accessibility_link_in_the_footer
    then_i_should_see_the_accessibility_statement
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

  def then_i_should_see_the_accessibility_statement
    expect(accessibility_page).to be_displayed
    expect(accessibility_page.page_heading).to have_text("Accessibility statement for Register trainee teachers")
  end

  def then_i_should_see_the_privacy_notice
    expect(privacy_notice_page).to be_displayed
    expect(privacy_notice_page.page_heading).to have_text("Register trainee teachers privacy notice")
  end
end
