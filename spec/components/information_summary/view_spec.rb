# frozen_string_literal: true

require "rails_helper"

module InformationSummary
  describe View, type: :component do
    context "when there is missing data content" do
      context "with header content" do
        let(:content) { "Some header content" }

        before do
          render_inline(described_class.new(renderable: true)) do |component|
            component.header { content }
          end
        end

        it "renders the given content from the block" do
          expect(rendered_component).to have_selector("p", text: content)
        end
      end

      context "with missing data items" do
        let(:missing_data_markup) do
          "<li><a class='govuk-notification-banner__link' href='#subject'>Subject is not recognised</a></li>".html_safe
        end

        before do
          render_inline(described_class.new(renderable: true)) do
            missing_data_markup
          end
        end

        it "renders the given content from the block" do
          expect(rendered_component).to have_selector("li", count: 1)
        end
      end
    end

    context "when renderable is false" do
      before do
        render_inline(described_class.new)
      end

      it "does not render" do
        expect(rendered_component).not_to have_css(".govuk-notification-banner")
      end
    end
  end
end
