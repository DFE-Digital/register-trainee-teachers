require "rails_helper"

RSpec.describe SummaryCard::View do
  rows = [
    { key: "Character", value: "Lando Calrissian" },
    { key: "Location", value: "In a galaxy" },
    { key: "Transport", value: "Falcon", action: '<a href="#mike" class="govuk-link">Change</a>'.html_safe },
  ]

  before(:all) do
    @result ||= render_inline(SummaryCard::View.new(title: "Lando Calrissian", heading_level: 6, rows: rows))
  end

  it "renders a summary list component for rows" do
    expect(@result.css(".govuk-summary-list__value").text).to include("Lando Calrissian")
    expect(@result.css(".govuk-summary-list__key").text).to include("Character")
  end

  it "renders content at the top of a summary card" do
    expect(@result.text).to include("In a galaxy")
  end

  it "renders a summary card header component with a title only" do
    expect(@result.css(".app-summary-card__title").text).to include("Lando Calrissian")
  end

  it "renders a summary card header component with a custom heading level" do
    expect(@result.css(".app-summary-card__title").text).to include("Lando Calrissian")
    expect(@result.css("h6.app-summary-card__title")).to be_present
  end

  it "renders a link alongside rows with an action value" do
    expect(@result.css(".govuk-link").text).to include("Change")
  end
end
