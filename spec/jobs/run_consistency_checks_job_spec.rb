# frozen_string_literal: true

require "rails_helper"

describe RunConsistencyChecksJob do
  include ActiveJob::TestHelper

  let(:trainee) { create(:trainee) }
  let(:consistency_check) { create(:consistency_check, trainee_id: trainee.id) }

  context "when a consistency check exists" do
    before do
      consistency_check

      described_class.perform_now
    end

    context "when the feature flag is turned on", feature_run_consistency_check_job: true do
      describe ".perform" do
        it "runs each check" do
          expect(Dttp::CheckConsistencyJob).to have_been_enqueued.with(consistency_check.id)
        end
      end
    end

    context "when the feature flag is turned off", feature_run_consistency_check_job: false do
      describe ".perform" do
        it "does not run" do
          expect(Dttp::CheckConsistencyJob).not_to have_been_enqueued.with(consistency_check.id)
        end
      end
    end
  end

  context "when there are no consistency checks", feature_run_consistency_check_job: true do
    describe ".perform" do
      it "does not run" do
        expect(Dttp::CheckConsistencyJob).not_to have_been_enqueued.with(consistency_check.id)
      end
    end
  end
end
