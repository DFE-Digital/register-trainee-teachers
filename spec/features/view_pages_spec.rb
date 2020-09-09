require "rails_helper"

RSpec.feature "view pages", type: :system do
  let(:home_page) { PageObjects::Home.new }

  before do
    home_page.load
  end

  scenario "navigate to home" do
    expect(home_page.hero).to have_text(t("hello"))
  end
end
