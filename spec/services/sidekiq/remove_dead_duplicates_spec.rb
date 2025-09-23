# frozen_string_literal: true

require "rails_helper"

module Sidekiq
  describe RemoveDeadDuplicates do
    let(:dead_set) { double }
    let(:args) { [{ "arguments" => [{ "_aj_globalid" => "gid://register-trainee-teachers/Trainee/12345" }] }] }
    let(:args2) { [{ "arguments" => [{ "trainee" => { "_aj_globalid" => "gid://register-trainee-teachers/Trainee/12345" } }] }] }
    let(:item) { { "error_message" => "status 404" } }
    let(:job1) { double(args: args, item: item, display_class: "Trs::UpdateTraineeJob") }
    let(:job2) { double(args: args2, item: item, display_class: "Trs::UpdateTraineeJob") }
    let(:job3) { double(args: args, item: { "error_message" => "status 429" }, display_class: "Dqt::WithdrawTraineeJob") }
    let(:dead_set_jobs) { [job1, job2, job3] }

    before do
      allow(Sidekiq::DeadSet).to receive(:new).and_return(dead_set)
      iterator = allow(dead_set).to receive(:each)
      dead_set_jobs.each do |job|
        allow(job).to receive(:delete)
        iterator.and_yield(job)
      end
      described_class.call
    end

    describe ".call" do
      it "deletes the duplicate job" do
        expect(job2).to have_received(:delete)
      end

      it "doesn't delete non-duplicate jobs" do
        expect(job1).not_to have_received(:delete)
        expect(job3).not_to have_received(:delete)
      end
    end
  end
end
