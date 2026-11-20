# frozen_string_literal: true

require "rails_helper"
require Rails.root.join("db/data/20261117090000_normalise_iqts_country_taiwan.rb")

RSpec.describe NormaliseIqtsCountryTaiwan do
  let(:taiwan_trainee) { create(:trainee, :iqts) }
  let(:other_trainee) { create(:trainee, :iqts, iqts_country: "Ireland") }

  before do
    taiwan_trainee.update_column(:iqts_country, "Taiwan [Taiwan, Province of China]")
  end

  describe "#up" do
    before { described_class.new.up }

    it "replaces the HESA label with the short form" do
      expect(taiwan_trainee.reload.iqts_country).to eq("Taiwan")
    end

    it "leaves other countries untouched" do
      expect(other_trainee.reload.iqts_country).to eq("Ireland")
    end
  end
end
