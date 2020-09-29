require "rails_helper"

RSpec.describe StartPageBanner::View do
  before(:all) do
    @result ||= render_inline(StartPageBanner::View.new)
  end

  it "renders a 'Get Started' button" do
    expect(@result.css(".app-start-page-banner__button").text).to include("Get started")
  end

  it "renders 'sign in' link" do
    expect(@result.css(".govuk-link").text).to include("sign in")
  end
end
