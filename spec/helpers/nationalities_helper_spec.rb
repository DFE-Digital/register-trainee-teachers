# frozen_string_literal: true

require "rails_helper"

describe NationalitiesHelper do
  include NationalitiesHelper

  let(:nationality) { build(:nationality, name: "british") }

  describe "#checkbox_nationalities" do
    let(:expected_nationality) do
      NationalityOption.new(
        id: nationality.name.titleize,
        name: nationality.name.titleize,
        description: t("views.default_nationalities.#{nationality.name}.description"),
      )
    end

    it "returns formatted versions of given nationality records" do
      nationality_option = checkbox_nationalities([nationality]).first
      expect(nationality_option.id).to eq(expected_nationality.id)
      expect(nationality_option.name).to eq(expected_nationality.name)
      expect(nationality_option.description).to eq(expected_nationality.description)
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
