# frozen_string_literal: true

require "rails_helper"

module Header
  describe View do
    alias_method :component, :page

    let(:items) { nil }

    before do
      render_inline(described_class.new)
    end

    it "does not render Service name" do
      expect(component).not_to have_text("Register")
    end

    it "does not render links" do
      expect(component).not_to have_css(".app-header__content")
    end
  end
end
