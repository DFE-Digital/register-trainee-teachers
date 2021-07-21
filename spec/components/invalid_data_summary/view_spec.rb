# frozen_string_literal: true

require "rails_helper"

module InvalidDataSummary
  describe View, type: :component do
    context "when there is invalid data" do
      let(:data) { { "degrees" => [{ "institution" => "University of Warwick" }] } }

      before do
        render_inline(described_class.new(data: data))
      end

      it "renders the summary text" do
        expected_text = I18n.t("invalid_data_summary.view.invalid_answers_summary", total_invalid_fields: 1)

        expect(rendered_component).to have_text(expected_text)
      end

      it "renders a list of links for each invalid field" do
        link_text = I18n.t("invalid_data_summary.view.invalid_answer_text", invalid_field: "Institution")
        expect(rendered_component).to have_link(link_text, href: "#institution")
      end
    end

    context "when data is empty" do
      let(:data) { {} }

      before do
        render_inline(described_class.new(data: data))
      end

      it "does not render" do
        expect(rendered_component).not_to have_css("body")
      end
    end
  end
end
