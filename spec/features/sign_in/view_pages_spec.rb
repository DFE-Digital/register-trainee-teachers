# frozen_string_literal: true

require "rails_helper"

RSpec.feature "view pages" do
  let(:sign_in_page) { PageObjects::SignIn.new }

  before do
    sign_in_page.load
  end

  scenario "navigate to sign in" do
    expect(sign_in_page.page_heading).to have_text("Sign in")
    expect(sign_in_page).to have_title("Sign in - Register trainee teachers - GOV.UK")
    expect(sign_in_page.sign_in_button.value).to eq("Sign in using Persona")
  end
end
