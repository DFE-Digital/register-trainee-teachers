require "rails_helper"

module Diversities
  describe DisabilityDetail do
    let(:trainee) { build(:trainee) }

    subject { described_class.new(trainee: trainee) }

    describe "validations" do
      context "disabilities" do
        before do
          subject.valid?
        end

        it "returns an error if its empty" do
          expect(subject.errors[:disability_ids]).to include(
            I18n.t(
              "activemodel.errors.models.diversities/disability_detail.attributes.disability_ids.empty_disabilities",
            ),
          )
        end
      end
    end
  end
end
