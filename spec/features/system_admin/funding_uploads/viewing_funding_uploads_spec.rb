# frozen_string_literal: true

require "rails_helper"

feature "Viewing funding uploads" do
  before do
    given_i_am_authenticated(user:)
    when_i_visit_the_root_page
    and_i_click_on_support_for_register
  end

  scenario "funding uploads feature flag is disabled", feature_funding_uploads: false do
    then_i_do_not_see_any_funding_links
    when_i_visit_the_funding_uploads_page
    then_i_see_the_not_found_page
  end

  scenario "navigate to the funding uploads page" do
    when_i_click_on_the_funding_link
    then_i_am_on_the_funding_uploads_page
    and_there_are_four_funding_upload_links
  end

private

  def user
    create(:user, :system_admin)
  end

  def when_i_visit_the_root_page
    visit "/"
  end

  def when_i_visit_the_funding_uploads_page
    visit "/system-admin/funding-uploads"
  end

  def then_i_do_not_see_any_funding_links
    expect(page).not_to have_link("Funding")
  end

  def then_i_only_see_payment_schedule_funding_links
    expect(page).to have_link("Funding", href: "/funding/payment-schedule")
    expect(page).not_to have_link("Funding", href: "/system-admin/funding-uploads")
  end

  def when_i_click_on_the_funding_link
    expect(page).not_to have_link("Funding", href: "/funding/payment-schedule")
    click_on("Funding")
  end

  def and_i_click_on_support_for_register
    click_on("Support for Register")
  end

  def then_i_am_on_the_funding_uploads_page
    expect(page).to have_current_path("/system-admin/funding-uploads")
  end

  def and_there_are_four_funding_upload_links
    expect(page.all(".govuk-table__cell > .govuk-link").map(&:text)).to match(
      ["Upload trainee summary",
       "Upload payment schedule",
       "Upload trainee summary",
       "Upload payment schedule"],
    )
  end
end
