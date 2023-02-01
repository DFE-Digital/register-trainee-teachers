# frozen_string_literal: true

require "rails_helper"

module Dqt
  describe WithdrawTraineeJob do
    include ActiveJob::TestHelper

    let(:trainee) { create(:trainee, :withdrawn, :submitted_for_trn) }
    let(:configured_poll_timeout_days) { 4 }
    let(:timeout_date) { configured_poll_timeout_days.days.from_now }
    let(:dqt_response) { {} }

    before do
      allow(WithdrawTrainee).to receive(:call).with(trainee:).and_return(nil)
      allow(RetrieveTeacher).to receive(:call).with(trainee:).and_return(dqt_response)
    end

    context "with the `integrate_with_dqt` feature flag inactive" do
      before do
        disable_features(:integrate_with_dqt)
      end

      it "does not call the WithdrawTrainee service" do
        expect(WithdrawTrainee).not_to receive(:call).with(trainee:)
        described_class.perform_now(trainee, timeout_date)
      end
    end

    context "with the `integrate_with_dqt` feature flag active" do
      before do
        enable_features(:integrate_with_dqt)
      end

      context "TRN is available" do
        let(:trainee) { create(:trainee, :withdrawn, :trn_received) }

        it "calls the WithdrawTrainee service" do
          expect(WithdrawTrainee).to receive(:call).with(trainee:)
          described_class.perform_now(trainee, timeout_date)
        end

        it "doesn't queue another job" do
          described_class.perform_now(trainee, timeout_date)
          expect(WithdrawTraineeJob).not_to have_been_enqueued
        end

        context "trainee is already withdrawn in DQT" do
          let(:dqt_response) { { "initial_teacher_training" => { "result" => "Withdrawn" } } }

          it "doesn't call the WithdrawTrainee service" do
            expect(WithdrawTrainee).not_to receive(:call).with(trainee:)
            described_class.perform_now(trainee, timeout_date)
          end
        end
      end

      context "TRN is not available" do
        let(:trainee) { create(:trainee, :withdrawn, :submitted_for_trn, trn: nil) }

        it "continues to wait until a TRN appears on the trainee record" do
          Timecop.freeze(Time.zone.now) do
            described_class.perform_now(trainee, timeout_date)
            expect(WithdrawTraineeJob).to have_been_enqueued.at(Settings.jobs.poll_delay_hours.hours.from_now)
                                                            .with(trainee, timeout_date)
          end
        end

        context "time_out after has passed" do
          it "doesn't queue another job" do
            expect(SlackNotifierService).to receive(:call)
            described_class.perform_now(trainee, 1.minute.ago)
            expect(WithdrawTraineeJob).not_to have_been_enqueued
          end
        end
      end
    end
  end
end
