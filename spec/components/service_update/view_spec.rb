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
      render_inline(described_class.new(service_update: service_update))
    end

    it "renders" do
      expect(rendered_component).to have_text("This is a title")
      expect(rendered_component).to have_text("This is a Markdown content.")
      expect(rendered_component).to have_text("8 November 2021")
    end
  end

  context "helper methods" do
    let(:component) { described_class.new(service_update: service_update) }

    it "renders content as Markdown html" do
      expect(component.content_html.strip).to eql("<p><em>This</em> is a <strong>Markdown</strong> content.</p>")
    end

    it "renders pretty date" do
      expect(component.date_pretty.strip).to eql("8 November 2021")
    end
  end
end
