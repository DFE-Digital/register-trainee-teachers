require "rails_helper"

describe ProgrammeDetail do
  let(:trainee) { build(:trainee) }

  subject { described_class.new(trainee: trainee) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:subject) }

    describe "custom" do
      before do
        subject.assign_attributes(attributes)
        subject.valid?
      end

      describe "age range valid" do
        let(:attributes) { { main_age_range: main_age_range } }
        context "main age range is blank" do
          let(:main_age_range) { "" }
          it "returns an error" do
            expect(subject.errors[:main_age_range]).to include(
              I18n.t(
                "activemodel.errors.models.programme_detail.attributes.main_age_range.blank",
              ),
            )
          end
        end

        context "main age range is 3-11" do
          let(:main_age_range) { "3-11" }
          it "does not return an error message" do
            expect(subject.errors[:main_age_range]).to be_empty
          end
        end

        context "main age range is other" do
          let(:attributes) { { main_age_range: :other, additional_age_range: additional_age_range } }
          context "additional age range is blank" do
            let(:additional_age_range) { "" }
            it "returns an error message" do
              expect(subject.errors[:additional_age_range]).to include(
                I18n.t(
                  "activemodel.errors.models.programme_detail.attributes.main_age_range.blank",
                ),
              )
            end
          end
          context "additional age range is 3-11" do
            let(:additional_age_range) { "3-11" }
            it "does not return an error message" do
              expect(subject.errors[:additional_age_range]).to be_empty
            end
          end
        end
      end
    end
  end
end
