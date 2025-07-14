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

  def when_i_click_on_the_funding_link
    expect(page).not_to have_link("Funding", href: "/funding/payment-schedule")
    click_on("Funding")
  end

  def and_i_click_on_support_for_register
    click_on("Support")
  end

  def then_i_am_on_the_funding_uploads_page
    expect(page).to have_current_path("/system-admin/funding-uploads")
  end

  def and_there_are_four_funding_upload_links
    expected_links = [
      { text: "Upload trainee summary", href: funding_type_url_for("lead_partner_trainee_summary") },
      { text: "Upload payment schedule", href: funding_type_url_for("lead_partner_payment_schedule") },
      { text: "Upload trainee summary", href: funding_type_url_for("provider_trainee_summary") },
      { text: "Upload payment schedule", href: funding_type_url_for("provider_payment_schedule") },
    ]

    actual_links = page.all(".govuk-table__cell > .govuk-link").map { |link| { text: link.text, href: link[:href] } }

    expect(actual_links).to match(expected_links)
  end

  def funding_type_url_for(funding_type) = "/system-admin/funding-uploads/new?funding_type=#{funding_type}"
end
