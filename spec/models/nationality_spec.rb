# frozen_string_literal: true

require "rails_helper"

describe Nationality do
  subject { build(:nationality) }

  describe "associations" do
    it { is_expected.to have_many(:nationalisations).inverse_of(:nationality) }
    it { is_expected.to have_many(:trainees).through(:nationalisations) }
  end

  describe "scopes" do
    describe "default" do
      let(:british) { create(:nationality, name: "british") }
      let(:irish) { create(:nationality, name: "irish") }
      let(:afghan) { create(:nationality, name: "afghan") }

      it "returns British and Irish nationalities" do
        expect(Nationality.default).to contain_exactly(british, irish)
      end

      it "does not return non default nationalities" do
        expect(Nationality.default).not_to include(afghan)
      end
    end

    describe "other" do
      let(:cypriot) { create(:nationality, name: "cypriot") }
      let(:eu_cypriot) { create(:nationality, name: "cypriot (european union)") }
      let(:non_eu_cypriot) { create(:nationality, name: "cypriot (non european union)") }

      it "does not return generic Cypriot option" do
        expect(Nationality.other).not_to include(cypriot)
      end

      it "returns other nationalities" do
        expect(Nationality.other).to contain_exactly(eu_cypriot, non_eu_cypriot)
      end
    end
  end
end
