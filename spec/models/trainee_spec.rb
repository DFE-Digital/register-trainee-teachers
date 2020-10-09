require "rails_helper"

describe Trainee do
  describe "database fields" do
    it { is_expected.to have_db_column(:locale_code).with_options(uk: 0, non_uk: 1) }
  end

  describe "associations" do
    it { is_expected.to have_many(:nationalisations).inverse_of(:trainee) }
    it { is_expected.to have_many(:nationalities).through(:nationalisations) }
  end

  describe ".dttp_id" do
    let(:uuid) { "2795182a-43b2-4543-bf83-ad95fbfce7fd" }

    context "when passed as an attribute" do
      it "uses the attribute" do
        trainee = create(:trainee, dttp_id: uuid)
        expect(trainee.dttp_id).to eq(uuid)
      end
    end

    context "when it has already been set" do
      it "raises an exception" do
        trainee = create(:trainee, dttp_id: uuid)

        expect { trainee.dttp_id = uuid }.to raise_error(LockedAttributeError)
      end
    end
  end
end
