# frozen_string_literal: true

require "rails_helper_axe"

RSpec.feature "view pages", axe: true,
                            driver: :selenium_headless do
  before :each do
    sign_in_page.load
  end

  let(:sign_in_page) { PageObjects::SignIn.new }

  scenario "navigate to sign in", "feature_use_dfe_sign_in": false do
    expect(sign_in_page.sign_in_button.text).to eq("Sign in using Persona")
    expect(sign_in_page).to be_axe_clean
  end

  scenario "navigate to sign in", "feature_use_dfe_sign_in": true do
    expect(sign_in_page.sign_in_button.value).to eq("Sign in using DfE Sign-in")
    expect(sign_in_page).to be_axe_clean
  end
end
