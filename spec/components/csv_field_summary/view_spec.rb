# frozen_string_literal: true

require "rails_helper"

module CsvFieldSummary
  describe View do
    include SummaryHelper

    alias_method :component, :page

    let(:description) { "Provider's own internal identifier for the student." }

    let(:attributes) do
      {
        "field_name" => "Provider trainee ID",
        "technical" => "provider_trainee_id",
        "hesa_alignment" => "OWNSTU",
        "description" => description,
        "format" => "20 character max length",
        "example" => '"99157234"',
      }
    end

    before do
      render_inline(View.new(attributes))
    end

    it "renders 6 rows" do
      expect(component).to have_css(".govuk-summary-list__row", count: 6)
    end

    it "renders the summary title" do
      expect(rendered_content).to have_css(".govuk-summary-list__value", text: attributes["field_name"])
    end

    it "renders the id" do
      expect(rendered_content).to have_css(".govuk-summary-list__value", text: attributes["technical"])
    end

    it "renders the HESA alignment" do
      expect(rendered_content).to have_css(".govuk-summary-list__value", text: attributes["hesa_alignment"])
    end

    it "renders the description" do
      expect(rendered_content).to have_css(".govuk-summary-list__value", text: attributes["description"])
    end

    it "renders the format" do
      expect(rendered_content).to have_css(".govuk-summary-list__value", text: attributes["format"])
    end

    it "renders the example" do
      expect(rendered_content).to have_css(".govuk-summary-list__value", text: attributes["example"])
    end

    context "with markdown in the description" do
      let(:description) do
        "Provider's own internal identifier for the _student_.\n\nThis field is *very important*."
      end

      it "renders the description as HTML" do
        expect(rendered_content).to include("<p>Provider&#39;s own internal identifier for the <em>student</em>.</p>")
        expect(rendered_content).to include("<p>This field is <em>very important</em>.</p>")
      end
    end
  end
end
