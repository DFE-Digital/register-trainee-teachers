# frozen_string_literal: true

require "rails_helper"

describe "config/recurring.yml" do
  let(:tasks) do
    config = ActiveSupport::ConfigurationFile.parse(Rails.root.join("config/recurring.yml")) || {}
    config.map { |key, options| SolidQueue::RecurringTask.from_configuration(key, **options.symbolize_keys) }
  end

  let(:sidekiq_cron_jobs) { YAML.load_file(Rails.root.join("config/sidekiq_cron_schedule.yml")) }

  it "only has valid tasks" do
    expect(tasks).to all(be_valid)
  end

  it "schedules every sidekiq-cron job at the same time on the same queue" do
    sidekiq_cron_jobs.each do |key, job|
      expect(tasks.find { |task| task.key == key }).to have_attributes(
        class_name: job["class"],
        queue_name: job["queue"],
        schedule: job["cron"],
      )
    end
  end

  it "removes duplicate failed Solid Queue jobs every 5 minutes" do
    expect(tasks.find { |task| task.key == "remove_duplicate_failed_jobs" }).to have_attributes(
      class_name: "SolidQueue::RemoveFailedDuplicatesJob",
      queue_name: "default",
      schedule: "*/5 * * * *",
    )
  end

  it "clears finished Solid Queue jobs on the default queue" do
    expect(tasks.find { |task| task.key == "clear_solid_queue_finished_jobs" }).to have_attributes(
      command: "SolidQueue::Job.clear_finished_in_batches(sleep_between_batches: 0.3)",
      queue_name: "default",
    )
  end
end
