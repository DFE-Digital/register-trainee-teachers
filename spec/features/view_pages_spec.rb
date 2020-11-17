# frozen_string_literal: true

require "rails_helper"

feature "view pages" do
  scenario "navigate to start" do
    given_i_am_on_the_home_page
    then_i_should_see_the_service_name
  end

  scenario "navigate to accessibility statement" do
    given_i_am_on_the_home_page
    and_i_click_on_the_accessibility_link_in_the_footer
    then_i_should_see_the_accessibility_statement
  end

private

  def given_i_am_on_the_home_page
    start_page.load
  end

  def then_i_should_see_the_service_name
    expect(start_page.page_heading).to have_text(t("page_headings.start_page"))
    expect(start_page).to have_title("Register trainee teachers - GOV.UK")
  end

  def and_i_click_on_the_accessibility_link_in_the_footer
    start_page.footer.accessibility_link.click
  end

  def then_i_should_see_the_accessibility_statement
    expect(accessibility_page).to be_displayed
    expect(accessibility_page.page_heading).to have_text("Accessibility statement for #{I18n.t('service_name')}")
  end

  def start_page
    @start_page ||= PageObjects::Start.new
  end

  def accessibility_page
    @accessibility_page ||= PageObjects::Accessibility.new
  end
end
