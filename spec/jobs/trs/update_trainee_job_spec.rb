# frozen_string_literal: true

require "rails_helper"

module Trs
  describe UpdateTraineeJob do
    describe "retries" do
      let(:trainee) { create(:trainee, :trn_received) }
      let(:failing_job) { described_class.new(trainee) }

      before do
        enable_features(:integrate_with_trs)
        allow(UpdatePersonalData).to receive(:call).and_raise(StandardError, "failed")
      end

      it_behaves_like "a job that retries on failure", attempts: 1
    end
  end
end
