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

    context "commencement date" do
      context "not present" do
        let(:params) { { commencement_date_radio_option: "manual", day: "", month: "", year: "" } }

        it "returns a blank error message" do
          expect(subject.errors[:commencement_date]).to include(
            I18n.t("#{error_attr}.commencement_date.blank"),
          )
        end
      end

      context "invalid date" do
        let(:params) { { commencement_date_radio_option: "manual", day: "2", month: "14", year: "" } }

        it "returns an invalid date error message" do
          expect(subject.errors[:commencement_date]).to include(
            I18n.t("#{error_attr}.commencement_date.invalid"),
          )
        end
      end

      context "invalid date year" do
        let(:params) { { commencement_date_radio_options: "manual", day: "1", month: "4", year: "21" } }

        it "returns an invalid year error message" do
          expect(subject.errors[:commencement_date]).to include(
            I18n.t("#{error_attr}.commencement_date.invalid_year"),
          )
        end
      end

      context "commencement date too far in the future" do
        let(:trainee) { build(:trainee, commencement_date: Date.parse("1/1/2099")) }

        it "returns an invalid year error message" do
          expect(subject.errors[:commencement_date]).to include(I18n.t("#{error_attr}.commencement_date.future"))
        end
      end

      context "date is before the course start date" do
        let(:trainee) do
          build(:trainee, course_start_date: Time.zone.today, commencement_date: 1.day.ago)
        end

        it "is invalid" do
          expect(subject.errors[:commencement_date]).to include(I18n.t("#{error_attr}.commencement_date.not_before_course_start_date"))
        end
      end
    end
  end
end
