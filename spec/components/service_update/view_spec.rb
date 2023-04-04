# frozen_string_literal: true

require "rails_helper"

describe ServiceUpdate::View do
  let(:service_update) {
    build(
      :service_update,
      title: "This is a title",
      content: "_This_ is a **Markdown** content.",
      date: "2021-11-08",
    )
  }

  context "render component" do
    before do
      render_inline(described_class.new(service_update:))
    end

    it "renders" do
      expect(page).to have_text("This is a title")
      expect(page).to have_text("This is a Markdown content.")
      expect(page).to have_text("8 November 2021")
    end
  end

  context "helper methods" do
    let(:component) { described_class.new(service_update:) }

    it "renders content as Markdown html" do
      expect(component.content_html.strip).to eql("<p><em>This</em> is a <strong>Markdown</strong> content.</p>")
    end

    it "renders pretty date" do
      expect(component.date_pretty.strip).to eql("8 November 2021")
    end

    describe "title_element" do
      context "by default" do
        it "returns an h2" do
          expect(component.title_element).to include("h2")
        end
      end

      context "when a title_tag is provided" do
        let(:component) { described_class.new(service_update:, title_tag:) }

        context "which is valid" do
          let(:title_tag) { "h3" }

          it "returns that tag" do
            expect(component.title_element).to include("h3")
          end
        end

        context "which is invalid" do
          let(:title_tag) { "hi" }

          it "returns an h2" do
            expect(component.title_element).to include("h2")
          end
        end
      end
    end
  end
end
