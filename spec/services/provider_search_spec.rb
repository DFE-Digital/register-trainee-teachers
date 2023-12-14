# frozen_string_literal: true

require "rails_helper"

describe ProviderSearch do
  let(:provider) { create(:provider) }

  describe "#call" do
    it "can search by code" do
      expect(described_class.call(query: provider.code).providers).to match([provider])
    end

    it "can search by ukprn" do
      expect(described_class.call(query: provider.ukprn).providers).to match([provider])
    end

    it "can search by name" do
      expect(described_class.call(query: provider.name).providers).to match([provider])
    end

    context "too many results" do
      before { create_list(:provider, 2, name: provider.name) }

      it "supports truncation" do
        expect(described_class.call(limit: 1).providers.size).to eq(1)
      end
    end

    context "search order" do
      let!(:provider_one) { create(:provider, name: "Acorn Park School, London") }
      let!(:provider_two) { create(:provider, name: "Beaumont Parking School, London") }
      let!(:provider_three) { create(:provider, name: "Parking School, London") }

      it "orders the results alphabetically" do
        expect(described_class.call.providers).to eq([provider_one, provider_two, provider_three])
      end

      context "with a search query" do
        it "orders the results alphabetically" do
          expect(described_class.call(query: "London").providers).to eq([provider_one, provider_two, provider_three])
        end
      end
    end

    context "with special characters" do
      let!(:provider_one) { create(:provider, name: "St Marys the Mount School") }
      let!(:provider_two) { create(:provider, name: "St Mary's Kilburn") }
      let!(:provider_three) { create(:provider, name: "Beaumont College - A Salutem/Ambito College") }

      it "matches all" do
        expect(described_class.call(query: "mary's").providers).to contain_exactly(provider_one, provider_two)
      end

      it "matches all without punctuations" do
        expect(described_class.call(query: "marys").providers).to contain_exactly(provider_one, provider_two)
      end

      it "ignores non-punctuation characters" do
        expect(described_class.call(query: "Salutem Ambito").providers).to eq([provider_three])
      end
    end

    context "limit" do
      it "can set a limit for the returned results" do
        expect(described_class.call(query: provider.ukprn, limit: 10).limit).to eq(10)
      end
    end
  end
end
