# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe Withdraw do
    let(:trainee) { create(:trainee) }
    let(:withdrawal_reasons) { [] }
    let(:withdrawal) { double(withdrawal_reasons:) }

    before do
      allow(Dqt::WithdrawTraineeJob).to receive(:perform_later)
      allow(Survey::ScheduleJob).to receive(:perform_later)
      allow(trainee).to receive(:current_withdrawal).and_return(withdrawal)
      allow(withdrawal_reasons).to receive(:pluck).with(:name).and_return(reason_names)
    end

    describe "#call" do
      it "queues a withdrawal to DQT" do
        expect(Dqt::WithdrawTraineeJob).to receive(:perform_later).with(trainee)
        described_class.call(trainee:)
      end

      context "when there are no withdrawal reasons" do
        let(:reason_names) { [] }

        it "does not schedule a survey" do
          expect(Survey::ScheduleJob).not_to receive(:perform_later)
          described_class.call(trainee:)
        end
      end

      context "when RECORD_ADDED_IN_ERROR is the only reason" do
        let(:reason_names) { [WithdrawalReasons::RECORD_ADDED_IN_ERROR] }

        it "does not schedule a survey" do
          expect(Survey::ScheduleJob).not_to receive(:perform_later)
          described_class.call(trainee:)
        end
      end

      context "when there are other reasons besides RECORD_ADDED_IN_ERROR" do
        let(:reason_names) { [WithdrawalReasons::RECORD_ADDED_IN_ERROR, "Another Reason"] }

        it "schedules a survey" do
          expect(Survey::ScheduleJob).to receive(:perform_later).with(trainee: trainee, event_type: :withdraw)
          described_class.call(trainee:)
        end
      end

      context "when there are only valid reasons" do
        let(:reason_names) { ["Valid Reason"] }

        it "schedules a survey" do
          expect(Survey::ScheduleJob).to receive(:perform_later).with(trainee: trainee, event_type: :withdraw)
          described_class.call(trainee:)
        end
      end
    end
  end
end
