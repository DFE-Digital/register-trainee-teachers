# frozen_string_literal: true

require "rails_helper"

module ProviderCard
  describe View do
    include SummaryHelper

    context "with a provider" do
      let(:provider) { create(:provider, name: "University of Wantage", code: "WG1") }
      let(:bob) { create(:user) }
      let(:alice) { create(:user) }
      let(:norman) { create(:user, discarded_at: 2.weeks.ago) }

      before do
        provider.users = []
        provider.users << bob << alice << norman

        render_inline(View.new(provider:))
      end

      it "render the correct provider details" do
        expect(rendered_content).to have_text("University of Wantage (WG1)")
        expect(rendered_content).to have_text("2 users")
        expect(rendered_content).not_to have_text("Previously accredited")
      end

      context "when the provider has lost accreditation" do
        let(:provider) { create(:provider, name: "University of Wantage", accredited: false, code: "WG1") }

        it "render the correct provider details and tag to indicate that the provider was previously accredited" do
          expect(rendered_content).to have_text("University of Wantage (WG1)")
          expect(rendered_content).to have_text("2 users")
          expect(rendered_content).to have_text("Previously accredited")
        end
      end
    end
  end
end
