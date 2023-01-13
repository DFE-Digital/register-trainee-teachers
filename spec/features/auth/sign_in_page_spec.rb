# frozen_string_literal: true

require "rails_helper"

feature "sign in page" do
  before do
    sign_in_page.load
  end

  scenario "navigate to sign in", feature_sign_in_method: "persona" do
    expect(sign_in_page.page_heading).to have_text("Sign in")
    expect(sign_in_page).to have_title("Sign in to Register trainee teachers - Register trainee teachers - GOV.UK")
    expect(sign_in_page.sign_in_button.text).to eq("Sign in using Persona")
  end

  scenario "navigate to sign in", feature_sign_in_method: "dfe-sign-in" do
    expect(sign_in_page.page_heading).to have_text("Sign in")
    expect(sign_in_page).to have_title("Sign in to Register trainee teachers - Register trainee teachers - GOV.UK")
    expect(sign_in_page.sign_in_button.text).to eq("Sign in using DfE Sign-in")
  end

  scenario "navigate to sign in", feature_sign_in_method: "otp" do
    expect(sign_in_page.page_heading).to have_text("Sign in")
    expect(sign_in_page).to have_title("Sign in to Register trainee teachers - Register trainee teachers - GOV.UK")
    expect(sign_in_page.otp_sign_in_button.text).to eq("Sign in using your email")
  end
end
