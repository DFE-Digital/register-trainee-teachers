require "rails_helper"

describe ProgrammeDetail do
  let(:trainee) { build(:trainee) }

  subject { described_class.new(trainee: trainee) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:subject) }

    describe "custom" do
      translation_key_prefix = "activemodel.errors.models.programme_detail.attributes"
      before do
        subject.assign_attributes(attributes)
        subject.valid?
      end

      describe "#age_range_valid" do
        let(:attributes) do
          { main_age_range: main_age_range }
        end

        context "main age range is blank" do
          let(:main_age_range) { "" }
          it "returns an error" do
            expect(subject.errors[:main_age_range]).to include(
              I18n.t(
                "#{translation_key_prefix}.main_age_range.blank",
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
          let(:attributes) do
            { main_age_range: :other,
              additional_age_range: additional_age_range }
          end
          context "additional age range is blank" do
            let(:additional_age_range) { "" }
            it "returns an error message" do
              expect(subject.errors[:additional_age_range]).to include(
                I18n.t(
                  "#{translation_key_prefix}.main_age_range.blank",
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

      describe "#programme_start_date_valid" do
        context "the date fields are all blank" do
          let(:attributes) do
            { "day" => "", "month" => "", "year" => "" }
          end
          it "returns an error" do
            expect(subject.errors[:programme_start_date]).to include(
              I18n.t(
                "#{translation_key_prefix}.programme_start_date.blank",
              ),
            )
          end
        end

        context "the date fields are 12/11/2020" do
          let(:attributes) do
            { "day" => "12", "month" => "11", "year" => "2020" }
          end
          it "does not return an error message" do
            expect(subject.errors[:programme_start_date]).to be_empty
          end
        end

        context "the date fields are are gibberish" do
          let(:attributes) do
            { "day" => "foo", "month" => "foo", "year" => "foo" }
          end
          it "return an error message" do
            expect(subject.errors[:programme_start_date]).to include(
              I18n.t(
                "#{translation_key_prefix}.programme_start_date.invalid",
              ),
            )
          end
        end
      end
    end
  end
end
