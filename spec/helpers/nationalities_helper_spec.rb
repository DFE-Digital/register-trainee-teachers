# frozen_string_literal: true

require "rails_helper"

describe NationalitiesHelper do
  include NationalitiesHelper

  let(:nationality) { build(:nationality, name: "british") }

  describe "#checkbox_nationalities" do
    let(:expected_nationality) do
      OpenStruct.new(
        id: nationality.name.titleize,
        name: nationality.name.titleize,
        description: t("views.default_nationalities.#{nationality.name}.description"),
      )
    end

    it "returns formatted versions of given nationality records" do
      expect(checkbox_nationalities([nationality])).to include(expected_nationality)
    end
  end

  describe "#nationalities_options" do
    it "returns correct nationality option array" do
      result = nationalities_options([nationality])
      expect(result.size).to be 2
      expect(result.first.name).to be ""
      expect(result.second.name).to eq nationality.name.titleize
    end
  end
end
