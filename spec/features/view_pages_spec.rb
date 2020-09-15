require "rails_helper"

RSpec.feature "view pages", type: :feature do
  let(:home_page) { PageObjects::Home.new }

  before do
    home_page.load
  end

  scenario "navigate to home", feature_home_text: true do
    expect(home_page.hero).to have_text(t("hello"))
  end
end
