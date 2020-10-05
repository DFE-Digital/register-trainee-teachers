require "rails_helper"

describe NationalitiesHelper do
  include NationalitiesHelper

  describe "#format_default_nationalities" do
    let(:nationality) { build(:nationality, name: name) }

    let(:expected_nationality) do
      OpenStruct.new(
        id: nationality.id,
        name: nationality.name.titleize,
        description: t("views.default_nationalities.#{nationality.name}.description"),
      )
    end

    context "default nationalities" do
      context "english" do
        let(:name) { "english" }

        it "returns formatted versions of given nationality records" do
          expect(format_default_nationalities([nationality])).to include(expected_nationality)
        end
      end

      context "irish" do
        let(:name) { "irish" }

        it "returns formatted versions of given nationality records" do
          expect(format_default_nationalities([nationality])).to include(expected_nationality)
        end
      end

      context "other" do
        let(:name) { "other" }

        it "returns formatted versions of given nationality records" do
          expect(format_default_nationalities([nationality])).to include(expected_nationality)
        end
      end
    end
  end
end
