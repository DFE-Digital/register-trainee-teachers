# frozen_string_literal: true

require "rails_helper"

module Personas
  describe View do
    alias_method :component, :page

    let(:persona_id) { 1 }
    let(:persona) { build(:user, id: persona_id, provider: build(:provider)) }

    before do
      render_inline(described_class.new(persona: persona))
    end

    it "renders persona's name" do
      expect(component).to have_text(persona.name)
    end

    it "renders the persona's provider name" do
      expect(component).to have_text(persona.provider.name)
    end

    it "renders a sign-in button to login as the persona" do
      expect(component.find("form")["action"]).to eq("/auth/developer/callback")
      expect(component).to have_selector(".govuk-button")
    end
  end
end
