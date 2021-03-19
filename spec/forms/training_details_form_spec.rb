# frozen_string_literal: true

require "rails_helper"

describe TrainingDetailsForm, type: :model do
  let(:trainee) { build(:trainee) }

  subject { described_class.new(trainee) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:trainee_id) }
  end

  describe "error messages" do
    before do
      subject.validate
    end

    context "trainee ID" do
      subject { described_class.new(trainee) }

      context "not present" do
        let(:trainee) { build(:trainee, trainee_id: nil) }

        it "returns a blank error message" do
          expect(subject.errors[:trainee_id]).to include(
            I18n.t("activemodel.errors.models.training_details_form.attributes.trainee_id.blank"),
          )
        end
      end

      context "over 100 characters" do
        let(:trainee) { build(:trainee, commencement_date: Time.zone.today, trainee_id: SecureRandom.alphanumeric(101)) }

        it "returns a max character exceeded message" do
          expect(subject).not_to be_valid
          expect(subject.errors[:trainee_id]).to include(
            I18n.t("activemodel.errors.models.training_details_form.attributes.trainee_id.max_char_exceeded"),
          )
        end
      end

      context "under 100 characters" do
        let(:trainee) { build(:trainee, commencement_date: Time.zone.today, trainee_id: SecureRandom.alphanumeric(99)) }

        it "is valid" do
          expect(subject).to be_valid
        end
      end
    end

    context "commencement date" do
      subject { described_class.new(trainee) }

      before do
        subject.assign_attributes(date_attributes)
        subject.validate
      end

      context "not present" do
        let(:date_attributes) { { day: "", month: "", year: "" } }

        it "returns a blank error message" do
          expect(subject.errors[:commencement_date]).to include(
            I18n.t("activemodel.errors.models.training_details_form.attributes.commencement_date.blank"),
          )
        end
      end

      context "invalid date" do
        let(:date_attributes) { { day: "2", month: "14", year: "" } }

        it "returns an invalid date error message" do
          expect(subject.errors[:commencement_date]).to include(
            I18n.t("activemodel.errors.models.training_details_form.attributes.commencement_date.invalid"),
          )
        end
      end
    end
  end
end
