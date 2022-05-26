# frozen_string_literal: true

require "rails_helper"

module Dqt
  describe WithdrawTraineeJob do
    let(:trainee) { create(:trainee, :withdrawn) }

    before do
      allow(WithdrawTrainee).to receive(:call).with(trainee: trainee).and_return(nil)
    end

    context "with the `integrate_with_dqt` feature flag active" do
      before do
        enable_features(:integrate_with_dqt)
      end

      it "calls the WithdrawTrainee service" do
        expect(WithdrawTrainee).to receive(:call).with(trainee: trainee)
        described_class.perform_now(trainee)
      end

      it "does not call the WithdrawTrainee service for a HESA trainee" do
        trainee.hesa_id = "12345678"
        expect(WithdrawTrainee).not_to receive(:call).with(trainee: trainee)
        described_class.perform_now(trainee)
      end
    end

    context "with the `integrate_with_dqt` feature flag inactive" do
      before do
        disable_features(:integrate_with_dqt)
      end

      it "does not call the WithdrawTrainee service" do
        expect(WithdrawTrainee).not_to receive(:call).with(trainee: trainee)
        described_class.perform_now(trainee)
      end
    end
  end
end
