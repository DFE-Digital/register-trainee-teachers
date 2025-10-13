# frozen_string_literal: true

require "rails_helper"

describe SummaryList::View do
  let(:rows) do
    [
      { key: "Character", value: "Lando Calrissian" },
      { key: "Location", value: "In a galaxy" },
      { key: "Transport", value: "Falcon", action_href: "#mike", action_text: "Change" },
    ]
  end

  subject do
    render_inline(SummaryList::View.new(rows: rows))
  end

  it "renders a summary list component for rows" do
    expect(subject.css(".govuk-summary-list__value").text).to include("Lando Calrissian")
    expect(subject.css(".govuk-summary-list__key").text).to include("Character")
  end

  it "renders content at the top of a summary list" do
    expect(subject.text).to include("In a galaxy")
  end

  it "does not render a title" do
    expect(subject.css(".app-summary-card__title")).to be_blank
  end

  it "renders a link alongside rows with an action value" do
    expect(subject.css(".govuk-link").text).to include("Change")
  end
end
