# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe SetCohortJob do
    let(:trainee) { double }

    it "calls SetCohort with the supplied trainee" do
      expect(SetCohort).to receive(:call).with(trainee: trainee)
      described_class.perform_now(trainee)
    end
  end
end
