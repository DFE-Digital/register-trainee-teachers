# frozen_string_literal: true

require "rails_helper"

module FeedbackLink
  describe View do
    alias_method :component, :page

    describe "feedback link" do
      before do
        render_inline(described_class.new(enabled: enabled,
                                          feedback_link_url: "https://www.google.com",
                                          feedback_type_text: "change status of a trainee for QTS"))
      end

      context "when enabled" do
        let(:enabled) { true }

        it "renders the feedback link" do
          expect(component).to have_link(
            "Give feedback (opens in a new tab)",
            href: "https://www.google.com",
          )
        end
      end

      context "when not enabled" do
        let(:enabled) { false }

        it "does not render the component" do
          expect(component).not_to have_css(".govuk-inset-text")
        end
      end
    end
  end
end
