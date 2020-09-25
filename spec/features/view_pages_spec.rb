require "rails_helper"

RSpec.feature "view pages" do
  let(:start_page) { PageObjects::Start.new }

  before do
    start_page.load
  end

  scenario "navigate to start" do
    expect(start_page.page_title).to have_text(t("page_headings.start_page"))
  end
end
