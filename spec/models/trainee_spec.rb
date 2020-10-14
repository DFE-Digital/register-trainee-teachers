require "rails_helper"

describe Trainee do
  describe "database fields" do
    it { is_expected.to have_db_column(:locale_code).with_options(uk: 0, non_uk: 1) }
  end

  describe "associations" do
    it { is_expected.to have_many(:degrees).dependent(:destroy) }
    it { is_expected.to have_many(:nationalisations).dependent(:destroy).inverse_of(:trainee) }
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

    describe "validation" do
      context "when record type is present" do
        subject { build(:trainee, record_type: "assessment_only") }

        it "is valid" do
          expect(subject).to be_valid
        end
      end

      context "when record type is not present" do
        it "is not valid" do
          expect(subject).not_to be_valid
          expect(subject.errors.keys).to include(:record_type)
        end
      end

      context "when trainee id is over 100 characters" do
        subject { build(:trainee, trainee_id: SecureRandom.alphanumeric(101)) }

        it "is not valid" do
          expect(subject).not_to be_valid
          expect(subject.errors.keys).to include(:trainee_id)
        end
      end

      context "when trainee id is under 100 characters" do
        subject { build(:trainee, trainee_id: SecureRandom.alphanumeric(99)) }

        it "is valid" do
          expect(subject).to be_valid
        end
      end
    end
  end
end
