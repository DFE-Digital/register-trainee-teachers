require "rails_helper"

describe PersonalDetail do
  let(:trainee) { build(:trainee) }

  subject { described_class.new(trainee: trainee) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:first_names) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:date_of_birth) }
    it { is_expected.to validate_presence_of(:gender) }

    context "nationalities" do
      before do
        subject.valid?
      end

      it "returns an error if its empty" do
        expect(subject.errors[:nationality_ids]).to include(
          I18n.t(
            "activemodel.errors.models.personal_detail.attributes.nationality_ids.empty_nationalities",
          ),
        )
      end
    end
  end
end
