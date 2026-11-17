# frozen_string_literal: true

require "rails_helper"
require Rails.root.join("db/data/20261117090001_normalise_degree_country_taiwan.rb")

RSpec.describe NormaliseDegreeCountryTaiwan do
  let(:taiwan_degree) { create(:degree, :non_uk_degree_type) }
  let(:kosovo_degree) { create(:degree, :non_uk_degree_type, country: "Kosovo") }

  before do
    # Bypasses the model normalisation, which is the state older rows are in.
    taiwan_degree.update_column(:country, "Taiwan [Taiwan, Province of China]")
  end

  describe "#up" do
    before { described_class.new.up }

    it "replaces the HESA label with the short form" do
      expect(taiwan_degree.reload.country).to eq("Taiwan")
    end

    it "leaves other countries untouched" do
      expect(kosovo_degree.reload.country).to eq("Kosovo")
    end
  end
end
