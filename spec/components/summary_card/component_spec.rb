require "rails_helper"

RSpec.describe SummaryCard::View do
  let(:rows) do
    {
      'Character': "Lando Calrissian",
    }
  end

  it "renders a summary list component for rows" do
    result = render_inline(SummaryCard::View.new(rows: rows))
    expect(result.css(".govuk-summary-list__value").text).to include("Lando Calrissian")
    expect(result.css(".govuk-summary-list__key").text).to include("Character")
  end

  it "renders content at the top of a summary card" do
    result = render_inline(SummaryCard::View.new(rows: rows)) { "In a galaxy" }
    expect(result.text).to include("In a galaxy")
  end
end
