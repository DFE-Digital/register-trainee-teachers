# frozen_string_literal: true

require "rails_helper"

module Survey
  describe SendJob do
    include ActiveJob::TestHelper

    let(:trainee) { create(:trainee) }

    context "when the qualtrics_survey feature is enabled", feature_qualtrics_survey: true do
      before do
        allow(Withdraw).to receive(:call)
        allow(Award).to receive(:call)
      end

      context "when event_type is :withdraw" do
        let(:event_type) { :withdraw }

        it "calls the Withdraw service" do
          expect(Withdraw).to receive(:call).with(trainee:)
          expect(Award).not_to receive(:call)

          described_class.perform_now(trainee:, event_type:)
        end
      end

      context "when event_type is :award" do
        let(:event_type) { :award }

        it "calls the Award service" do
          expect(Award).to receive(:call).with(trainee:)
          expect(Withdraw).not_to receive(:call)

          described_class.perform_now(trainee:, event_type:)
        end
      end
    end

    context "when the qualtrics_survey feature is disabled", feature_qualtrics_survey: false do
      before do
        allow(Withdraw).to receive(:call)
        allow(Award).to receive(:call)
      end

      it "does not call any service" do
        expect(Withdraw).not_to receive(:call)
        expect(Award).not_to receive(:call)

        described_class.perform_now(trainee: trainee, event_type: :withdraw)
      end
    end
  end
end
