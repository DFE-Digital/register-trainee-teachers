# frozen_string_literal: true

require "rails_helper"

module ProviderCard
  describe View do
    include SummaryHelper

    context "with a provider" do
      let(:provider) { create(:provider, name: "University of Wantage") }
      let(:bob) { create(:user) }
      let(:alice) { create(:user) }
      let(:norman) { create(:user, discarded_at: 2.weeks.ago) }

      before do
        provider.users << bob << alice << norman

        render_inline(View.new(provider:))
      end

      it "render the correct provider details" do
        expect(rendered_component).to have_text("University of Wantage")
        expect(rendered_component).to have_text("2 users")
      end
    end
  end
end
