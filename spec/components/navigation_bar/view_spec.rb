# frozen_string_literal: true

require "rails_helper"

module NavigationBar
  include ApplicationHelper

  describe View do
    alias_method :component, :page

    let(:mock_link) { "https://www.gov.uk" }

    before do
      render_inline(described_class.new(items: items))
    end

    context "multiple links" do
      let(:items) do
        [
          { name: "Home", url: mock_link },
          { name: "Trainee records", url: mock_link },
        ]
      end

      it "has two change links" do
        expect(component).to have_link("Home")
        expect(component).to have_link("Trainee records")
      end
    end










    context "where item current is true" do
      let(:current_item) { { name: "Bulk actions", url: mock_link, current: true } }
      let(:items) { [current_item] }

      it "renders the link with aria-current" do
        rendered_link = component.find(".moj-primary-navigation__link", text: current_item[:name])
        expect(rendered_link["aria-current"]).to eq("page")
      end
    end

    context "where item current is false" do
      let(:non_current_item) { { name: "Trainee records", url: mock_link, current: false} }
      let(:items) { [non_current_item] }

      context "when not on the current url" do
        it "renders the link without aria-current" do
          rendered_link = component.find(".moj-primary-navigation__link", text: non_current_item[:name])
          expect(rendered_link["aria-current"]).to eq(nil)
        end
      end

      context "when on the current url" do
        before do
          allow(ApplicationHelper.helpers).to receive(:current_page?).with(mock_link).and_return(true)
        end

        it "renders the link with aria-current" do
          rendered_link = component.find(".moj-primary-navigation__link", text: non_current_item[:name])
          expect(rendered_link["aria-current"]).to eq("page")
        end
      end
    end

    context "where item current is not set" do
      let(:item) { { name: "Trainee records", url: mock_link } }

      context "when not on the current url" do

      end

      context "when on the current url" do

      end
    end
  end
end
