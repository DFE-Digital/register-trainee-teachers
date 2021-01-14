# frozen_string_literal: true

require "rails_helper"

RSpec.describe StartPageBanner::View do
  before(:all) do
    @result ||= render_inline(StartPageBanner::View.new)
  end

  it "renders a 'Sign in' button" do
    expect(@result.css(".app-start-page-banner__button").text).to include("Sign in")
  end

  it "renders 'or request an account' link" do
    expect(@result.css(".app-link--inverted").text).to include("request an account")
  end
end
