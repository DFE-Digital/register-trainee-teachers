# frozen_string_literal: true

require "rails_helper"

module NavigationBar
  describe View do
    alias_method :component, :page

    let(:mock_link) { "https://www.gov.uk" }
    let(:items) do
      [
        { name: "Home", url: mock_link },
        { name: "Trainee records", url: mock_link },
      ]
    end

    before do
      render_inline(described_class.new(user, items: items))
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

      context "with current item" do
        let(:active_item) { { name: "Bulk actions", url: mock_link, current: true } }

        before do
          render_inline(described_class.new(:user, items: items.prepend(active_item)))
        end

        it "renders the current item with the correct class" do
          rendered_link = component.find(".moj-primary-navigation__link", text: active_item[:name])
          expect(rendered_link["aria-current"]).to eq("page")
        end
      end
    end
  end
end
