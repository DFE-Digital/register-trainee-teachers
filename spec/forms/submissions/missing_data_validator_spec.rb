# frozen_string_literal: true

require "rails_helper"

module Submissions
  describe MissingDataValidator, type: :model do
    describe "validations" do
      subject { described_class.new(trainee: trainee) }

      context "when all sections are valid" do
        let(:trainee) { build(:trainee, :completed) }

        it "is valid" do
          expect(subject.valid?).to be true
          expect(subject.errors).to be_empty
        end
      end

      context "when a section is invalid" do
        let(:trainee) { build(:trainee, :completed, first_names: nil) }

        it "is invalid and returns an error message" do
          expect(subject.valid?).to be false
          expect(subject.errors.messages[:trainee])
            .to include(I18n.t("activemodel.errors.models.submissions/missing_data_validator.attributes.trainee.incomplete"))
        end
      end
    end

    describe "#missing_fields" do
      subject { described_class.new(trainee: trainee) }

      context "when trainee has no missing data" do
        let(:trainee) { build(:trainee, :completed) }

        it "returns an empty array" do
          expect(subject.missing_fields).to be_empty
        end
      end

      context "when trainee has missing data" do
        let(:trainee) { build(:trainee, :completed, first_names: nil) }

        it "returns the correct attributes from the invalid form" do
          expect(subject.missing_fields).to contain_exactly(:first_names)
        end
      end
    end
  end
end
