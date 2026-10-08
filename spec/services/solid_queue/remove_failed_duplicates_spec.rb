# frozen_string_literal: true

require "rails_helper"

module SolidQueue
  describe RemoveFailedDuplicates do
    let(:trainee_gid) { "gid://register-trainee-teachers/Trainee/12345" }

    let!(:job1) { create_failed_job("Trs::UpdateTraineeJob", [{ "_aj_globalid" => trainee_gid }], "status 404") }
    let!(:job2) { create_failed_job("Trs::UpdateTraineeJob", [{ "trainee" => { "_aj_globalid" => trainee_gid } }], "status 404") }
    let!(:job3) { create_failed_job("Trs::UpdateProfessionalStatusJob", [{ "_aj_globalid" => trainee_gid }], "status 429") }

    before do
      described_class.call
    end

    describe ".call" do
      it "deletes the older duplicate job" do
        expect(SolidQueue::Job.exists?(job1.id)).to be(false)
      end

      it "doesn't delete the latest duplicate or non-duplicate jobs" do
        expect(SolidQueue::Job.exists?(job2.id)).to be(true)
        expect(SolidQueue::Job.exists?(job3.id)).to be(true)
      end
    end

    def create_failed_job(class_name, arguments, error)
      job = SolidQueue::Job.create!(
        class_name: class_name,
        queue_name: "trs",
        arguments: { "job_class" => class_name, "arguments" => arguments },
      )
      job.ready_execution.destroy!
      job.failed_with(StandardError.new(error))
      job
    end
  end
end
