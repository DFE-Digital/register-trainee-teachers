# frozen_string_literal: true

require "rails_helper"

feature "sign in user not found page" do
  scenario "navigate to the page with the feedback link enabled" do
    enable_features("enable_feedback_link")
    sign_in_user_not_found_page.load

    expect(sign_in_user_not_found_page.page_heading).to have_text("Ask for an account to register trainee teachers")
    expect(sign_in_user_not_found_page).to have_text(
      "You have a DfE Sign-in account, but you also need an account for this service.",
    )

    expect(sign_in_user_not_found_page).to have_text("How to get access")
    expect(sign_in_user_not_found_page).to have_text(
      "Ask a colleague who already has access to email becomingateacher@digital.education.gov.uk to request access for you.",
    )
    expect(sign_in_user_not_found_page).to have_text("Their email must include:")
    expect(sign_in_user_not_found_page.email_requirements.map(&:text)).to eq(
      [
        "the name of the accredited provider or training partner you both work for",
        "the email address you use for DfE Sign-in",
      ],
    )
    expect(sign_in_user_not_found_page).to have_text(
      "If more than one person needs access, you can include their details in the same email.",
    )
    expect(sign_in_user_not_found_page.inset_text).to have_text(
      "If you do not know who at your organisation has access, email becomingateacher@digital.education.gov.uk and we will send you a list of contacts.",
    )

    expect(sign_in_user_not_found_page).to have_text("Already requested access?")
    expect(sign_in_user_not_found_page).to have_text(
      "If a colleague has already emailed on your behalf, you do not need to do anything else. We will contact you when your account is ready.",
    )

    expect(sign_in_user_not_found_page.home_button.text).to eq("Return home")
  end

  scenario "navigate to the page with the feedback link disabled" do
    disable_features("enable_feedback_link")
    sign_in_user_not_found_page.load

    expect(sign_in_user_not_found_page.page_heading).to have_text("Ask for an account to register trainee teachers")
    expect(sign_in_user_not_found_page).to have_text(
      "You have a DfE Sign-in account, but you also need an account for this service.",
    )

    expect(sign_in_user_not_found_page).not_to have_text("How to get access")
    expect(sign_in_user_not_found_page.main_content).not_to have_text("becomingateacher@digital.education.gov.uk")
    expect(sign_in_user_not_found_page).not_to have_css(".govuk-inset-text")
    expect(sign_in_user_not_found_page).not_to have_text("Already requested access?")

    expect(sign_in_user_not_found_page.home_button.text).to eq("Return home")
  end
end
