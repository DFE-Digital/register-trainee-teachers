# frozen_string_literal: true

require "rails_helper"

describe TrainingDetailsForm, type: :model do
  let(:params) { {} }
  let(:trainee) { build(:trainee) }
  let(:error_attr) { "activemodel.errors.models.training_details_form.attributes" }

  subject { described_class.new(trainee, params: params) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:trainee_id) }
  end

  describe "error messages" do
    before do
      subject.validate
    end

    context "trainee ID" do
      context "not present" do
        let(:trainee) { build(:trainee, trainee_id: nil) }

        it "returns a blank error message" do
          expect(subject.errors[:trainee_id]).to include(
            I18n.t("#{error_attr}.trainee_id.blank"),
          )
        end
      end

      context "over 100 characters" do
        let(:trainee) { build(:trainee, commencement_date: Time.zone.today, trainee_id: SecureRandom.alphanumeric(101)) }

        it "returns a max character exceeded message" do
          expect(subject).not_to be_valid
          expect(subject.errors[:trainee_id]).to include(
            I18n.t("#{error_attr}.trainee_id.max_char_exceeded"),
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
  end
end
