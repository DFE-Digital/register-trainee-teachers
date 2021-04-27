# frozen_string_literal: true

require "rails_helper"

describe NationalitiesHelper do
  include NationalitiesHelper

  describe "#format_nationalities" do
    let(:nationality) { build(:nationality, name: name) }

    context "default nationalities" do
      let(:expected_nationality) do
        OpenStruct.new(
          id: nationality.name.titleize,
          name: nationality.name.titleize,
          description: t("views.default_nationalities.#{nationality.name}.description"),
        )
      end

      context "english" do
        let(:name) { "english" }

        it "returns formatted versions of given nationality records" do
          expect(format_nationalities([nationality])).to include(expected_nationality)
        end
      end

      context "irish" do
        let(:name) { "irish" }

        it "returns formatted versions of given nationality records" do
          expect(format_nationalities([nationality])).to include(expected_nationality)
        end
      end

      context "other" do
        let(:name) { "other" }

        it "returns formatted versions of given nationality records" do
          expect(format_nationalities([nationality])).to include(expected_nationality)
        end
      end
    end

    context "with description: false" do
      let(:name) { "english" }

      let(:expected_nationality) do
        OpenStruct.new(
          id: nationality.name.titleize,
          name: nationality.name.titleize,
        )
      end

      it "returns formatted versions of given nationality records" do
        expect(format_nationalities([nationality], description: false)).to include(expected_nationality)
      end
    end

    context "with empty_option: true" do
      let(:name) { "english" }
      let(:empty_option) { OpenStruct.new(id: "", name: "") }

      let(:expected_nationality) do
        OpenStruct.new(
          id: nationality.name.titleize,
          name: nationality.name.titleize,
          description: t("views.default_nationalities.#{nationality.name}.description"),
        )
      end

      it "returns formatted versions of given nationality records with an empty option first" do
        format_nationalities = format_nationalities([nationality], empty_option: true)
        expect(format_nationalities).to eq([empty_option, expected_nationality])
      end
    end
  end
end
