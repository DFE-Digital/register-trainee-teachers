# frozen_string_literal: true

require "rails_helper"

describe ApplicationJob do
  before do
    stub_const("FailingJob", Class.new(described_class) { def perform = raise(StandardError, "failed") })
  end

  let(:failing_job) { FailingJob.new }

  it_behaves_like "a job that retries on failure", attempts: 26
end
