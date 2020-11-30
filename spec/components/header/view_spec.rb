# frozen_string_literal: true

require "rails_helper"

module Header
  describe View do
    alias_method :component, :page

    before do
      render_inline(described_class.new("Test Service"))
    end

    it "renders Service's name" do
      expect(component.find(".govuk-header__product-name")).to have_text("Test Service")
    end

    it "does not render Sign out link" do
      expect(component).not_to have_selector(".app-header__content")
    end

    context "when a user is signed in" do
      let(:user) { build(:user) }

      before do
        render_inline(described_class.new("Test Service", user))
      end

      it "renders the Sign out link" do
        expect(component.find_all(".app-header__content .govuk-header__link").length).to eq(1)
      end
    end
  end
end
