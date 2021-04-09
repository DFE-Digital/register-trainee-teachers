# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe ImportProvider do
    subject { described_class.call(provider_hash: provider_hash) }

    let(:provider_hash) { ApiStubs::Dttp::Provider.attributes }

    it "creates a Dttp::Provider record" do
      expect {
        subject
      }.to change(Dttp::Provider, :count).by(1)
    end

    it "creates a record with the provider_hash" do
      subject
      expect(Dttp::Provider.last.name).to eq("Test Organisation")
    end

    context "when the Dttp::Provider already exists" do
      let!(:dttp_provider) { create(:dttp_provider, dttp_id: provider_hash["accountid"]) }

      it "does not create a new Dttp::Provider record" do
        expect {
          subject
        }.not_to change(Dttp::Provider, :count)
      end

      it "updates the existing record" do
        subject
        dttp_provider.reload
        expect(dttp_provider.name).to eq("Test Organisation")
      end
    end
  end
end
