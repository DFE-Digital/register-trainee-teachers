# frozen_string_literal: true

require "rails_helper"

module BlueInsetTextWithLink
  describe View do
    alias_method :component, :page
    let(:title) { "title" }
    let(:link_text) { "link_text" }
    let(:url) { "url" }

    before do
      render_inline(
        described_class.new(title: title, link_text: link_text, url: url),
      )
    end

    context "when personal details not started" do
      let(:progress) { nil }
      let(:section) { :personal_details }

      it "title" do
        expect(component).to have_css(".app-inset-text__title", text: title)
      end

      it "link" do
        expect(component).to have_link(link_text, href: url)
      end

      it "renders the correct css classes" do
        expect(component).to have_css(".govuk-inset-text.app-inset-text--narrow-border.app-inset-text--important")
      end
    end
  end
end
