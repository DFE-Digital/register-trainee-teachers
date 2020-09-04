require "rails_helper"

RSpec.describe SummaryTableComponent, type: :component do
  let(:content_hash) { { Name: "Alfred" } }
  let(:doc) { render_inline(described_class.new(content_hash: content_hash)) }

  context "output" do
    it "renders keys" do
      expect(doc.css(".govuk-summary-list .govuk-summary-list__row .govuk-summary-list__key").to_html).to include("Name")
    end

    it "renders values" do
      expect(doc.css(".govuk-summary-list .govuk-summary-list__row .govuk-summary-list__value").to_html).to include("Alfred")
    end
  end

  describe "#formatted_attribute_id" do
    let(:content_hash) { { "Trainee ID" => "Alfred" } }
    let(:expected_key) { "trainee-id" }

    subject { described_class.new(content_hash: content_hash) }

    it "formats the provided key of content hash" do
      expect(subject.formatted_attribute_id(content_hash.keys.first)).to eq(expected_key)
    end
  end
end
