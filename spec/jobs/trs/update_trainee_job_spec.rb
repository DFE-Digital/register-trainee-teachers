# frozen_string_literal: true

require "rails_helper"

module Trs
  describe UpdateTraineeJob do
    include ActiveJob::TestHelper

    subject { described_class.new.perform(trainee) }

    before do
      enable_features(:integrate_with_trs)
      allow(UpdatePersonPii).to receive(:call)
    end

    context "when integrate_with_trs is enabled" do
      context "with a trainee that has a TRN and is in a valid state" do
        let(:trainee) { create(:trainee, :trn_received) }

        it "calls the UpdatePersonPii service" do
          subject
          expect(UpdatePersonPii).to have_received(:call).with(trainee:)
        end
      end

      context "with a trainee that does not have a TRN" do
        let(:trainee) { create(:trainee, :trn_received, trn: nil) }

        it "does not call the UpdatePersonPii service" do
          subject
          expect(UpdatePersonPii).not_to have_received(:call)
        end
      end

      Config::INVALID_UPDATE_STATES.each do |state|
        context "with a trainee in the #{state} state" do
          let(:trainee) { create(:trainee, state.to_sym, trn: "12345678") }

          it "does not call the UpdatePersonPii service" do
            subject
            expect(UpdatePersonPii).not_to have_received(:call)
          end
        end
      end
    end

    context "when integrate_with_trs is disabled" do
      let(:trainee) { create(:trainee, :trn_received) }

      before do
        disable_features(:integrate_with_trs)
      end

      it "does not call the UpdatePersonPii service" do
        subject
        expect(UpdatePersonPii).not_to have_received(:call)
      end
    end
  end
end
