# frozen_string_literal: true

require "rails_helper"

RSpec.feature "view pages" do
  let(:sign_in_page) { PageObjects::SignIn.new }

  before do
    sign_in_page.load
  end

  scenario "navigate to sign in", "feature_use_dfe_sign_in": false do
    expect(sign_in_page.page_heading).to have_text("Sign in")
    expect(sign_in_page).to have_title("Sign in - Register trainee teachers - GOV.UK")
    expect(sign_in_page.sign_in_button.text).to eq("Sign in using Persona")
  end

  scenario "navigate to sign in", "feature_use_dfe_sign_in": true do
    expect(sign_in_page.page_heading).to have_text("Sign in")
    expect(sign_in_page).to have_title("Sign in - Register trainee teachers - GOV.UK")
    expect(sign_in_page.sign_in_button.value).to eq("Sign in using DfE Sign-in")
  end
end
