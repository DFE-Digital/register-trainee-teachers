# frozen_string_literal: true

require "rails_helper"

module CsvFields
  describe View do
    include SummaryHelper

    alias_method :component, :page

    before do
      render_inline(View.new)
    end

    let(:data) { YAML.load_file(CsvFields::View::FIELD_DEFINITION_PATH) }

    it "renders the correct number of summary components" do
      expect(component).to have_css(".govuk-summary-list", count: data.count)
    end

    it "renders the summary titles as links" do
      data.each do |field|
        expect(rendered_content).to have_css(
          "a[href=\"#summary-card-#{field['technical'].parameterize}\"]",
          text: field["field_name"],
        )
      end
    end

    it "renders the summary components with the correct ids" do
      data.each do |field|
        expect(rendered_content).to have_css(
          "section#summary-card-#{field['technical'].parameterize}",
        )
      end
    end
  end
end
