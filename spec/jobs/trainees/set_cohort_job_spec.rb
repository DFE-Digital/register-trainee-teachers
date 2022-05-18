# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe SetCohortJob do
    let(:trainee) { double }

    context "feature enabled" do
      before { enable_features(:set_trainee_cohort) }

      it "calls SetCohort with the supplied trainee" do
        expect(SetCohort).to receive(:call).with(trainee: trainee)
        described_class.perform_now(trainee)
      end
    end

    context "feature not enabled" do
      before { disable_features(:set_trainee_cohort) }

      it "does not call SetCohort" do
        expect(SetCohort).not_to receive(:call)
        described_class.perform_now(trainee)
      end
    end
  end
end
