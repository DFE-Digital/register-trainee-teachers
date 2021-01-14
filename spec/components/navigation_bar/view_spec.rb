# frozen_string_literal: true

require "rails_helper"

module NavigationBar
  describe View do
    alias_method :component, :page

    before do
      render_inline(described_class.new(user))
    end

    context "when user is not signed in" do
      let(:user) { nil }

      it "does not render the navigation bar" do
        expect(component).to_not have_css(".moj-primary-navigation")
      end
    end

    context "when user is signed in" do
      let(:user) { build(:user) }

      it "renders the navigation bar" do
        expect(component).to have_css(".moj-primary-navigation")
      end

      it "has two change links" do
        expect(component).to have_link("Home")
        expect(component).to have_link("Trainee records")
      end
    end
  end
end
