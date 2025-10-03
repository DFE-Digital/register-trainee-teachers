# frozen_string_literal: true

require "rails_helper"

describe SidekiqJobsHelper do
  include SidekiqJobsHelper

  around { |example| Timecop.freeze { example.run } }

  let(:trainee) { build(:trainee) }
  let(:last_run_at) { 3.days.ago }
  let(:scheduled_to_run_at) { 2.hours.from_now }

  describe "#last_run_or_scheduled_at" do
    context "when there is a dead job" do
      before do
        allow(Trs::FindDeadJobs).to receive(:call).and_return(
          trainee.id => {
            job_id: "dead_job_id",
            error_message: "dead_job_error_message",
            scheduled_at: last_run_at,
          },
        )
        allow(Trs::FindRetryJobs).to receive(:call).and_return({})
      end

      it "returns the last time the dead job ran" do
        expect(last_run_or_scheduled_at(trainee)).to eq(last_run_at)
      end
    end

    context "when there is a retry job" do
      before do
        allow(Trs::FindDeadJobs).to receive(:call).and_return({})
        allow(Trs::FindRetryJobs).to receive(:call).and_return(
          trainee.id => {
            job_id: "retry_job_id",
            error_message: "retry_job_error_message",
            scheduled_at: scheduled_to_run_at,
          },
        )
      end

      it "returns the next time the job is scheduled to re-run" do
        expect(last_run_or_scheduled_at(trainee)).to eq(scheduled_to_run_at)
      end
    end

    context "when there is no job in Sidekiq" do
      before do
        allow(Trs::FindDeadJobs).to receive(:call).and_return({})
        allow(Trs::FindRetryJobs).to receive(:call).and_return({})
      end

      it "returns nil" do
        expect(last_run_or_scheduled_at(trainee)).to be_nil
      end
    end
  end

  describe "#job_status" do
    context "when there is a dead job" do
      before do
        allow(Trs::FindDeadJobs).to receive(:call).and_return(
          trainee.id => {
            job_id: "dead_job_id",
            error_message: "dead_job_error_message",
            scheduled_at: last_run_at,
          },
        )
        allow(Trs::FindRetryJobs).to receive(:call).and_return({})
      end

      it "the status is `dead`" do
        expect(job_status(trainee)).to eq("dead")
      end
    end

    context "when there is a retry job" do
      before do
        allow(Trs::FindDeadJobs).to receive(:call).and_return({})
        allow(Trs::FindRetryJobs).to receive(:call).and_return(
          trainee.id => {
            job_id: "retry_job_id",
            error_message: "retry_job_error_message",
            scheduled_at: scheduled_to_run_at,
          },
        )
      end

      it "the status is `retrying`" do
        expect(job_status(trainee)).to eq("retrying")
      end
    end

    context "when there is no job in Sidekiq" do
      before do
        allow(Trs::FindDeadJobs).to receive(:call).and_return({})
        allow(Trs::FindRetryJobs).to receive(:call).and_return({})
      end

      it "the status is `unknown`" do
        expect(job_status(trainee)).to eq("unknown")
      end
    end
  end
end
