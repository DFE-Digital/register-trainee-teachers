# frozen_string_literal: true

require "rails_helper"

module ErrorSummary
  describe View, type: :component do
    context "when there are errors" do
      let(:error_markup) {  "<li>This is an error item</li>".html_safe }

      before do
        render_inline(described_class.new(renderable: true)) do
          error_markup
        end
      end

      it "renders the given content from the block" do
        expect(rendered_component).to have_selector("li", count: 1)
      end
    end

    context "when has_errors is false" do
      before do
        render_inline(described_class.new(renderable: false))
      end

      it "does not render" do
        expect(rendered_component).not_to have_css(".govuk-error-summary")
      end
    end
  end
end
