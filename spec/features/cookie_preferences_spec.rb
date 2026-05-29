# frozen_string_literal: true

require "rails_helper"

feature "navigate to cookies preferences" do
  scenario "save preference" do
    given_i_am_on_the_start_page
    then_i_should_see_the_cookie_banner
    when_i_click_on_the_cookies_link_in_the_footer
    and_i_give_consent_and_submit
    then_i_go_back_to_the_start_page
    and_i_should_not_see_the_cookie_banner
  end

  scenario "shows accept and reject buttons when JS is enabled", js: true do
    given_i_am_on_the_start_page
    then_i_should_see_the_cookie_banner
    and_i_should_see_the_cookie_accept_button
    and_i_should_see_the_cookie_reject_button
  end

private

  def and_i_should_see_the_cookie_accept_button
    expect(page).to have_button(t("cookies.accept"), visible: :visible)
  end

  def and_i_should_see_the_cookie_reject_button
    expect(page).to have_button(t("cookies.reject"), visible: :visible)
  end

  def given_i_am_on_the_start_page
    start_page.load
  end

  def when_i_click_on_the_cookies_link_in_the_footer
    start_page.footer.cookies_link.click
  end

  def and_i_give_consent_and_submit
    edit_cookie_preferences_page.yes_option.choose
    edit_cookie_preferences_page.submit_button.click
  end

  def then_i_should_see_the_cookie_banner
    expect(start_page).to have_text(t("cookies.heading"))
  end

  def then_i_go_back_to_the_start_page
    edit_cookie_preferences_page.back_link.click
  end

  def and_i_should_not_see_the_cookie_banner
    expect(start_page).not_to have_text(t("cookies.heading"))
  end
end
