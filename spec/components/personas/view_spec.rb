# frozen_string_literal: true

require "rails_helper"

module Personas
  describe View do
    alias_method :component, :page

    let(:persona_id) { 1 }
    let(:persona) { create(:user, id: persona_id, providers: build_list(:provider, 1)) }

    before do
      render_inline(described_class.new(persona:))
    end

    it "renders persona's name" do
      expect(component).to have_text(persona.name)
    end

    it "renders a sign-in button to login as the persona" do
      expect(component.find("form")["action"]).to eq("/auth/developer/callback")
      expect(component).to have_css(".govuk-button")
    end

    context "single provider" do
      it "renders the persona's provider name" do
        expect(component).to have_text(persona.providers.first.name)
      end
    end

    context "multiple providers" do
      let(:persona) { create(:user, id: persona_id, providers: build_list(:provider, 2)) }

      it "renders the all provider names" do
        persona.providers.each do |provider|
          expect(component).to have_text("#{provider.name} (#{provider.code})")
        end
      end
    end

    context "multiple lead partners" do
      let(:persona) { create(:user, id: persona_id, lead_partners: create_list(:lead_partner, 2, :school)) }

      it "renders the all provider names" do
        persona.lead_partners.each do |lead_partner|
          expect(component).to have_text(lead_partner.name)
        end
      end
    end
  end
end
