# frozen_string_literal: true

require "rails_helper"

module ApplyApplications
  describe TraineeDataForm, type: :model do
    subject { described_class.new(trainee) }

    describe "validations" do
      context "when one or more of the forms is invalid" do
        let(:trainee) { create(:trainee, :with_apply_application) }

        before do
          subject.valid?
        end

        it "returns the entire form as invalid" do
          expect(subject.progress).to be false
          expect(subject.errors).not_to be_empty
        end

        it "does not validate the degrees form" do
          expect(subject.progress_status(:degrees)).to eq(:not_provided)
        end

        context "when degree is not required" do
          let(:trainee) { create(:trainee, :teacher_degree_apprenticeship, :with_apply_application, degrees: []) }

          it "does not validate the degrees form" do
            expect(subject.progress_status(:degrees)).to eq(:not_provided)
          end

          it "returns the entire form as invalid" do
            expect(subject.progress).to be false
            expect(subject.errors).not_to be_empty
          end
        end
      end

      context "when all of the forms are valid" do
        let(:trainee) { create(:trainee, :with_apply_application, :completed) }

        it "returns the entire form as invalid" do
          expect(subject.progress).to be true
          expect(subject.errors).to be_empty
        end

        it "validates the degrees form" do
          expect(subject.progress_status(:degrees)).to eq(:completed)
        end

        context "when degree is not required" do
          let(:trainee) { create(:trainee, :teacher_degree_apprenticeship, :with_apply_application, :completed, degrees: []) }

          it "validates the degrees form" do
            expect(subject.progress_status(:degrees)).to eq(:not_provided)
          end

          it "returns the entire form as invalid" do
            expect(subject.progress).to be true
            expect(subject.errors).to be_empty
          end
        end
      end
    end
  end
end
