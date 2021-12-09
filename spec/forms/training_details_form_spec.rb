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

      context "duplicate" do
        let!(:existing_trainee) { create(:trainee, trainee_id: "Test123") }
        let(:trainee) { build(:trainee, provider: existing_trainee.provider, trainee_id: "TEST123") }

        it "returns a duplicate error message" do
          expect(subject.errors[:trainee_id]).to include(
            I18n.t("#{error_attr}.trainee_id.uniqueness"),
          )
          expect(subject.duplicate_error?).to be_truthy
        end
      end

      context "same id but different provider" do
        let!(:existing_trainee) { create(:trainee, trainee_id: "Test123") }
        let(:trainee) { build(:trainee, trainee_id: "TEST123") }

        it "returns a duplicate error message" do
          expect(subject.errors[:trainee_id]).not_to include(
            I18n.t("#{error_attr}.trainee_id.uniqueness"),
          )
          expect(subject.duplicate_error?).to be_falsey
        end
      end
    end
  end

  describe "#existing_trainee_with_id" do
    context "same provider and id" do
      let!(:existing_trainee) { create(:trainee, trainee_id: "Test123") }
      let(:trainee) { build(:trainee, provider: existing_trainee.provider, trainee_id: "TEST123") }

      it "returns existing_trainee" do
        expect(subject.send(:existing_trainee_with_id)).to eql(existing_trainee)
      end
    end

    context "different provider and same id" do
      let!(:existing_trainee) { create(:trainee, trainee_id: "Test123") }
      let(:trainee) { build(:trainee, trainee_id: "TEST123") }

      it "returns existing_trainee" do
        expect(subject.send(:existing_trainee_with_id)).not_to eql(existing_trainee)
      end
    end
  end

  describe "#existing_short_name" do
    let!(:existing_trainee) { create(:trainee, trainee_id: "Test123") }
    let(:trainee) { build(:trainee, provider: existing_trainee.provider, trainee_id: "TEST123") }

    it "returns short_name" do
      expect(subject.existing_short_name).to eql(existing_trainee.short_name)
    end
  end

  describe "#existing_created" do
    context "today" do
      let!(:existing_trainee) { create(:trainee, trainee_id: "Test123", created_at: Time.zone.now) }
      let(:trainee) { build(:trainee, provider: existing_trainee.provider, trainee_id: "TEST123") }

      it "returns today" do
        expect(subject.existing_created).to eql("today")
      end
    end

    context "yesterday" do
      let!(:existing_trainee) { create(:trainee, trainee_id: "Test123", created_at: 1.day.ago) }
      let(:trainee) { build(:trainee, provider: existing_trainee.provider, trainee_id: "TEST123") }

      it "returns yesterday" do
        expect(subject.existing_created).to eql("yesterday")
      end
    end

    context "other dates" do
      let!(:existing_trainee) { create(:trainee, trainee_id: "Test123", created_at: 10.days.ago) }
      let(:trainee) { build(:trainee, provider: existing_trainee.provider, trainee_id: "TEST123") }

      it "returns date formatted" do
        expect(subject.existing_created).to eql(existing_trainee.created_at.strftime("%-d %B %Y"))
      end
    end
  end

  describe "remove white space" do
    let(:trainee) { build(:trainee, trainee_id: "  TEST123  ") }

    it "returns short_name" do
      subject.valid?
      expect(subject.trainee_id).to eql("TEST123")
    end
  end
end
