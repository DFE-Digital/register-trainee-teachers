# frozen_string_literal: true

RSpec.shared_examples "a job that retries on failure" do |attempts:|
  include ActiveJob::TestHelper

  it "runs #{attempts} #{'time'.pluralize(attempts)} before failing" do
    runs = 0
    job_data = failing_job.serialize

    expect {
      loop do
        runs += 1
        ActiveJob::Base.execute(job_data)
        job_data = enqueued_jobs.pop
      end
    }.to raise_error(StandardError)

    expect(runs).to eq(attempts)
  end
end
