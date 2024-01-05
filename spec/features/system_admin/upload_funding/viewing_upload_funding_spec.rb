# frozen_string_literal: true

require "rails_helper"

feature "Viewing upload funding" do
  before do
    given_i_am_authenticated(user:)
    when_i_visit_the_root_page
  end

  context "user is a system admin" do
    let(:user) { create(:user, :system_admin) }

    scenario "upload funding feature flag is disabled", feature_upload_funding: false do
      then_i_do_not_see_any_funding_links

      when_i_visit_the_upload_funding_page
      then_i_see_the_not_found_page
    end

    scenario "navigate to the upload funding page" do
      when_i_click_on_the_funding_link
      then_i_am_on_the_upload_funding_page
      and_there_are_four_upload_funding_links
    end
  end

  context "user is a non system admin" do
    let(:user) { create(:user) }

    scenario "the system admin funding link is not available" do
      then_i_only_see_payment_schedule_funding_links
    end
  end

private

  def when_i_visit_the_root_page
    visit "/"
  end

  def when_i_visit_the_upload_funding_page
    visit "/system-admin/upload-funding"
  end

  def then_i_do_not_see_any_funding_links
    expect(page).not_to have_link("Funding")
  end

  def then_i_only_see_payment_schedule_funding_links
    expect(page).to have_link("Funding", href: "/funding/payment-schedule")
    expect(page).not_to have_link("Funding", href: "/system-admin/upload-funding")
  end

  def when_i_click_on_the_funding_link
    expect(page).not_to have_link("Funding", href: "/funding/payment-schedule")
    click_on("Funding")
  end

  def then_i_am_on_the_upload_funding_page
    expect(page).to have_current_path("/system-admin/upload-funding")
  end

  def and_there_are_four_upload_funding_links
    expect(page.all(".govuk-table__cell > .govuk-link").map(&:text)).to match(
      ["Upload trainee summary",
       "Upload payment schedule",
       "Upload trainee summary",
       "Upload payment schedule"],
    )
  end
end
