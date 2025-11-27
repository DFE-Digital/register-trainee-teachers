# frozen_string_literal: true

require "rails_helper"

module TrainingPartnerResultNotice
  describe View, type: :component do
    let(:search_query) { "oxf" }
    let(:search_limit) { 15 }

    context "default rendering" do
      let(:expected_count) { search_count - search_limit }

      before do
        render_inline(
          described_class.new(
            search_query:,
            search_limit:,
            search_count:,
          ),
        )
      end

      context "when difference is 1" do
        let(:search_count) { 16 }

        it "renders the remaining search count" do
          expected_text = I18n.t("components.lead_partner_result_notice.result_text", search_query:)

          expect(rendered_content).to have_text(expected_text)
        end
      end

      context "when difference is more than one" do
        let(:search_count) { 30 }

        it "renders the pluralised remaining search count" do
          expected_text = I18n.t(
            "components.lead_partner_result_notice.multiple_result_text",
            search_query: search_query,
            remaining_search_count: expected_count,
          )

          expect(rendered_content).to have_text(expected_text)
        end
      end
    end

    context "when total is negative" do
      let(:search_count) { 8 }

      it "does not render" do
        expect(rendered_content).not_to have_css("body")
      end
    end
  end
end
