# frozen_string_literal: true

require "rails_helper"

module Personas
  describe View do
    alias_method :component, :page

    let(:persona_id) { 1 }
    let(:persona) { create(:user, id: persona_id, providers: create_list(:provider, 1)) }

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
      let(:persona) { create(:user, id: persona_id, providers: create_list(:provider, 2)) }

      it "renders the all provider names" do
        persona.providers.each do |provider|
          expect(component).to have_text(provider.name)
        end
      end
    end

    context "multiple lead schools" do
      let(:persona) { create(:user, id: persona_id, lead_schools: create_list(:school, 2, :lead)) }

      it "renders the all provider names" do
        persona.lead_schools.each do |lead_school|
          expect(component).to have_text(lead_school.name)
        end
      end
    end
  end
end
