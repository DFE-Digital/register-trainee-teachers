# frozen_string_literal: true

require "rails_helper"

feature "sign in user not found page" do
  scenario "navigate to the page with the feedback link enabled" do
    enable_features("enable_feedback_link")
    sign_in_user_not_found_page.load

    expect(sign_in_user_not_found_page.page_heading).to have_text("Ask for an account to register trainee teachers")
    expect(sign_in_user_not_found_page).to have_text(
      "Although you have a DfE Sign-in account, you also need an account for this service.",
    )
    expect(sign_in_user_not_found_page).to have_text("Contact us at becomingateacher@digital.education.gov.uk to ask for an account.")
    expect(sign_in_user_not_found_page.home_button.text).to eq("Return home")
  end

  scenario "navigate to the page with the feedback link disabled" do
    disable_features("enable_feedback_link")
    sign_in_user_not_found_page.load

    expect(sign_in_user_not_found_page.page_heading).to have_text("Ask for an account to register trainee teachers")
    expect(sign_in_user_not_found_page).not_to have_text("to ask for an account")
  end
end
