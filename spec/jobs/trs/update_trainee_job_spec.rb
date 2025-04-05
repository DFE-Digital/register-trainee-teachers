# frozen_string_literal: true

require "rails_helper"

module Trs
  describe UpdateTraineeJob do
    include ActiveJob::TestHelper

    before do
      allow(FeatureService).to receive(:enabled?).with(any_args).and_return(false)
      allow(FeatureService).to receive(:enabled?).with(:integrate_with_trs).and_return(true)
    end

    subject { described_class.new.perform(trainee) }

    describe "#perform" do
      context "with the feature enabled and a trn in a valid state" do
        let(:trainee) { create(:trainee, :trn_received) }

        before do
          allow(trainee).to receive(:reload).and_return(trainee)
          allow(UpdatePersonalData).to receive(:call)
        end

        it "calls the UpdatePersonalData service" do
          subject
          expect(UpdatePersonalData).to have_received(:call).with(trainee:)
        end
      end

      context "with a trainee that does not have a TRN" do
        let(:trainee) { create(:trainee, :trn_received, trn: nil) }

        before do
          allow(trainee).to receive(:reload).and_return(trainee)
          allow(UpdatePersonalData).to receive(:call)
        end

        it "does not call the UpdatePersonalData service" do
          subject
          expect(UpdatePersonalData).not_to have_received(:call)
        end
      end

      CodeSets::Trs::INVALID_UPDATE_STATES.each do |state|
        context "with a trainee in the #{state} state" do
          let(:trainee) { create(:trainee, state.to_sym, trn: "12345678") }

          before do
            allow(trainee).to receive(:reload).and_return(trainee)
            allow(UpdatePersonalData).to receive(:call)
          end

          it "does not call the UpdatePersonalData service" do
            subject
            expect(UpdatePersonalData).not_to have_received(:call)
          end
        end
      end
    end

    context "when integrate_with_trs is disabled" do
      let(:trainee) { create(:trainee, :trn_received) }

      before do
        allow(FeatureService).to receive(:enabled?).with(:integrate_with_trs).and_return(false)
        allow(trainee).to receive(:reload).and_return(trainee)
        allow(UpdatePersonalData).to receive(:call)
      end

      it "does not call the UpdatePersonalData service" do
        subject
        expect(UpdatePersonalData).not_to have_received(:call)
      end
    end
  end
end
