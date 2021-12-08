# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe CreateFromDttpJob do
    include ActiveJob::TestHelper
    let(:state) { :unprocessed }
    let(:provider) { create(:provider) }
    let(:dttp_trainee) { create(:dttp_trainee, provider: provider, state: state) }

    describe "#perform", feature_import_trainees_from_dttp: true do
      context "when provider is available" do
        it "creates a trainee" do
          expect(CreateFromDttp).to receive(:call).with(dttp_trainee: dttp_trainee)

          described_class.perform_now
        end

        context "when dttp_trainee is already processed" do
          let(:state) { :processed }

          it "does not create a trainee" do
            expect(CreateFromDttp).not_to receive(:call).with(dttp_trainee: dttp_trainee)

            described_class.perform_now
          end
        end
      end

      context "when provider is not available" do
        let(:dttp_trainee) { create(:dttp_trainee, state: state) }

        it "does not create a trainee" do
          expect(CreateFromDttp).not_to receive(:call).with(dttp_trainee: dttp_trainee)

          described_class.perform_now
        end
      end
    end
  end
end
