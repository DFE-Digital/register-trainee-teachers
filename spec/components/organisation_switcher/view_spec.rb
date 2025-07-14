# frozen_string_literal: true

require "rails_helper"

module OrganisationSwitcher
  describe View do
    alias_method :component, :page

    let(:user) { nil }
    let(:organisation) { nil }
    let(:session) { {} }
    let(:multiple_organisations) { false }

    let(:current_user) { UserWithOrganisationContext.new(user:, session:) }

    before do
      allow(current_user).to receive_messages(organisation: organisation, multiple_organisations?: multiple_organisations)

      render_inline(described_class.new(current_user:))
    end

    context "when the user is NOT logged out" do
      let(:current_user) { nil }

      it "does not render" do
        expect(component).not_to have_css(".app-organisation-switcher")
      end
    end

    context "when the user does not have an organisation" do
      let(:user) { build(:user) }

      it "does not render" do
        expect(component).not_to have_css(".app-organisation-switcher")
      end
    end

    context "when the user has a single organisation" do
      let(:user) { build(:user) }
      let(:organisation) { build(:provider) }

      it "does render" do
        expect(component).to have_css(".app-organisation-switcher")
      end

      it "renders the organisation name" do
        expect(component).to have_content(organisation.name)
      end

      it "does not render the _Change organisation_ link" do
        expect(component).not_to have_css(".app-organisation-switcher__link", text: "Change organisation")
      end

      it "renders the _Organisation settings_ link" do
        expect(component).to have_css(".app-organisation-switcher__link", text: "Organisation settings")
      end
    end

    context "when the user has multiple organisations" do
      let(:user) { build(:user) }
      let(:organisation) { build(:provider) }
      let(:multiple_organisations) { true }

      it "does render" do
        expect(component).to have_css(".app-organisation-switcher")
      end

      it "renders the organisation name" do
        expect(component).to have_content(organisation.name)
      end

      it "renders the _Change organisation_ link" do
        expect(component).to have_css(".app-organisation-switcher__link", text: "Change organisation")
      end

      it "renders the _Organisation settings_ link" do
        expect(component).to have_css(".app-organisation-switcher__link", text: "Organisation settings")
      end
    end
  end
end
