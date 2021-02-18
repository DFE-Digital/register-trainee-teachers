# frozen_string_literal: true

require "rails_helper"

describe TrnSubmissionForm, type: :model do
  subject { described_class.new(trainee: full_trainee) }

  let(:full_trainee) do
    create(
      :trainee,
      :with_start_date,
      :with_programme_details,
      ethnic_background: "some background",
      nationalities: [create(:nationality)],
      disabilities: [create(:disability)],
      degrees: [create(:degree, :uk_degree_with_details)],
      progress: progress,
    )
  end

  shared_examples "error" do
    it "is invalid and returns an error message" do
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:trainee]).to include(I18n.t("activemodel.errors.models.trn_submission_form.attributes.trainee.incomplete"))
    end
  end

  describe "validations" do
    context "when all sections are valid and complete" do
      let(:progress) do
        {
          degrees: true,
          diversity: true,
          contact_details: true,
          personal_details: true,
          programme_details: true,
          training_details: true,
        }
      end

      it "is valid" do
        expect(subject.valid?).to be true
        expect(subject.errors).to be_empty
      end
    end

    context "when any section is invalid or incomplete" do
      let(:progress) do
        {
          degrees: nil,
          diversity: false,
          contact_details: true,
          personal_details: true,
          programme_details: true,
          training_details: true,
        }
      end
      include_examples "error"
    end

    context "with empty progress" do
      let(:progress) { {} }
      include_examples "error"
    end
  end
end
