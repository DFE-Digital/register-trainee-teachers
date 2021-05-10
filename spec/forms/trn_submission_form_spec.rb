# frozen_string_literal: true

require "rails_helper"

describe TrnSubmissionForm, type: :model do
  let(:trainee) { create(:trainee, :completed, progress: progress) }

  shared_examples "error" do
    it "is invalid and returns an error message" do
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:trainee]).to include(I18n.t("activemodel.errors.models.trn_submission_form.attributes.trainee.incomplete"))
    end
  end

  describe "validations" do
    context "when all sections are valid and complete" do
      subject { described_class.new(trainee: trainee) }
      let(:progress) do
        {
          degrees: true,
          diversity: true,
          contact_details: true,
          personal_details: true,
          course_details: true,
          training_details: true,
        }
      end

      it "is valid" do
        expect(subject.valid?).to be true
        expect(subject.errors).to be_empty
      end

      context "requires school" do
        let(:trainee) { create(:trainee, :school_direct_salaried, :with_lead_school, :with_employing_school, :completed, progress: progress.merge(schools: true)) }

        it "is valid" do
          expect(subject.valid?).to be true
          expect(subject.errors).to be_empty
        end
      end
    end

    context "when any section is invalid or incomplete" do
      subject { described_class.new(trainee: trainee) }

      let(:progress) do
        {
          degrees: nil,
          diversity: false,
          contact_details: true,
          personal_details: true,
          course_details: true,
          training_details: true,
        }
      end

      include_examples "error"

      context "requires school but incomplete" do
        let(:trainee) { create(:trainee, :school_direct_salaried, :with_lead_school, progress: progress.merge(schools: false)) }

        include_examples "error"
      end
    end

    context "with empty progress" do
      subject { described_class.new(trainee: trainee) }
      let(:progress) { {} }
      include_examples "error"
    end
  end
end
