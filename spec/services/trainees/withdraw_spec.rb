# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe Withdraw do
    let(:trainee) { create(:trainee) }

    describe "#call" do
      it "queues a withdrawal to DQT when `withdrawal` option is set" do
        expect(Dqt::WithdrawTraineeJob).to receive(:perform_later).with(trainee)
        described_class.call(trainee:)
      end
    end
  end
end
