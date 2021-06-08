# frozen_string_literal: true

require "rails_helper"

describe SchoolSearch do
  let(:school) { create(:school) }

  describe "#call" do
    it "can search by urn" do
      expect(described_class.call(query: school.urn)).to match([school])
    end

    it "can search by name" do
      expect(described_class.call(query: school.name)).to match([school])
    end

    it "can search by town" do
      expect(described_class.call(query: school.town)).to match([school])
    end

    it "can search by postcode" do
      expect(described_class.call(query: school.postcode)).to match([school])
    end

    context "database has open and closed schools" do
      let(:open_school) { create(:school, :open) }

      before do
        create(:school, :closed)
      end

      it "only returns schools that are open" do
        expect(described_class.call).to match([open_school])
      end
    end

    context "too many results" do
      before { create_list(:school, 2, name: school.name) }

      it "supports truncation" do
        expect(described_class.call(limit: 1).size).to eq(1)
      end
    end

    context "search order" do
      let!(:school_two) { create(:school, name: "The London Acorn School") }
      let!(:school_one) { create(:school, name: "Acorn Park School") }

      it "orders the results alphabetically" do
        expect(described_class.call).to eq([school_one, school_two])
      end

      context "with a search query" do
        it "orders the results alphabetically" do
          expect(described_class.call(query: "acorn")).to eq([school_one, school_two])
        end
      end
    end

    context "with special characters" do
      let!(:school_two) { create(:school, name: "St Mary's Kilburn") }
      let!(:school_one) { create(:school, name: "St Marys the Mount School") }

      it "matches all" do
        expect(described_class.call(query: "mary's")).to match_array([school_one, school_two])
      end

      it "matches all without punctuations" do
        expect(described_class.call(query: "marys")).to match_array([school_one, school_two])
      end
    end

    context "searching lead schools" do
      let(:lead_school) { create(:school, lead_school: true) }

      before do
        create(:school)
      end

      it "has a option to only search for lead schools" do
        expect(described_class.call(lead_schools_only: true)).to match([lead_school])
      end
    end
  end
end
