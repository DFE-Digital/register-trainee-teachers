require "rails_helper"

RSpec.describe SummaryTableComponent, type: :component do
  let(:content_hash) { { Name: "Alfred" } }
  let(:doc) { render_inline(described_class.new(content_hash: content_hash)) }

  it "renders keys" do
    expect(doc.css(".govuk-summary-list .govuk-summary-list__row .govuk-summary-list__key").to_html).to include("Name")
  end

  it "renders values" do
    expect(doc.css(".govuk-summary-list .govuk-summary-list__row .govuk-summary-list__value").to_html).to include("Alfred")
  end
end
