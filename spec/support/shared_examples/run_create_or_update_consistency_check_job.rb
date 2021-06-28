# frozen_string_literal: true

require "rails_helper"

shared_examples "CreateOrUpdateConsistencyCheckJob" do |model|
  describe ".perform" do
    it "enqueues the CreateOrUpdateConsistencyJob" do
      expect {
        model.call(trainee: trainee)
      }.to have_enqueued_job(Dttp::CreateOrUpdateConsistencyCheckJob).with(trainee)
    end
  end
end
