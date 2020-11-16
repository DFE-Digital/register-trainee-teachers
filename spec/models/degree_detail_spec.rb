require "rails_helper"

describe DegreeDetail do
  let(:trainee) { build(:trainee) }

  subject { described_class.new(trainee) }

  describe "validations" do
    context "degrees" do
      before do
        subject.valid?
      end

      context "with degrees" do
        before do
          trainee.degrees << build(:degree)
        end

        it { is_expected.to be_valid }
      end

      context "with no degrees" do
        it "returns an error if its empty" do
          expect(subject.errors[:degree_ids]).to include(
            I18n.t(
              "activemodel.errors.models.degree_detail.attributes.degree_ids.empty_degrees",
            ),
          )
        end
      end
    end
  end
end
