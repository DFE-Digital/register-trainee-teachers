# frozen_string_literal: true

require "rails_helper"

module NavigationBar
  describe View do
    alias_method :component, :page

    let(:item_url) { "https://www.gov.uk" }
    let(:current_path) { item_url }
    let(:current_user) { build(:user) }

    before do
      render_inline(described_class.new(items:, current_path:, current_user:))
    end

    context "service name" do
      let(:items) { [] }

      it "renders the service name" do
        expect(component).to have_text(I18n.t("service_name"))
      end
    end

    context "multiple links" do
      let(:items) do
        [
          { name: "Home", url: item_url },
          { name: "Trainee records", url: item_url },
        ]
      end

      it "has two change links" do
        expect(component).to have_link("Home")
        expect(component).to have_link("Trainee records")
      end
    end

    context "right aligned links" do
      let(:items) do
        [
          { name: "Home", url: item_url },
          { name: "Trainee records", url: item_url },
          { name: "Right aligned", url: item_url, align_right: true },
        ]
      end

      it "shows right aligned links" do
        expect(component).to have_link("Home")
        expect(component).to have_link("Trainee records")
        expect(component.find(".govuk-service-navigation__item.app-service-navigation__align_right")).to have_text("Right aligned")
      end
    end

    context "where item current is true" do
      let(:current_item) { { name: "Bulk actions", url: item_url, current: true } }
      let(:current_path) { "http://www.google.com" }
      let(:items) { [current_item] }

      it "renders the link with aria-current" do
        rendered_link = component.find(".govuk-service-navigation__link", text: current_item[:name])
        expect(rendered_link["aria-current"]).to eq("page")
      end
    end

    context "where item current is false" do
      let(:non_current_item) { { name: "Trainee records", url: item_url, current: false } }
      let(:items) { [non_current_item] }

      context "when not on the current url" do
        let(:current_path) { "http://www.google.com" }

        it "renders the link without aria-current" do
          rendered_link = component.find(".govuk-service-navigation__link", text: non_current_item[:name])
          expect(rendered_link["aria-current"]).to be_nil
        end
      end

      context "when on the current url" do
        it "renders the link with aria-current" do
          rendered_link = component.find(".govuk-service-navigation__link", text: non_current_item[:name])
          expect(rendered_link["aria-current"]).to eq("page")
        end
      end
    end

    context "where item current is not set" do
      let(:no_current_item) { { name: "Trainee records", url: item_url } }
      let(:items) { [no_current_item] }

      context "when not on the current url" do
        let(:current_path) { "http://www.google.com" }

        it "renders the link without aria-current" do
          rendered_link = component.find(".govuk-service-navigation__link", text: no_current_item[:name])
          expect(rendered_link["aria-current"]).to be_nil
        end
      end

      context "when on the current url" do
        it "renders the link with aria-current" do
          rendered_link = component.find(".govuk-service-navigation__link", text: no_current_item[:name])
          expect(rendered_link["aria-current"]).to eq("page")
        end
      end
    end
  end
end
