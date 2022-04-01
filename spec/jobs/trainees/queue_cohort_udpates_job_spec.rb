# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe QueueCohortUpdatesJob do
    let(:current_trainee) { create(:trainee, :current) }
    let(:past_trainee) { create(:trainee, :past) }
    let(:future_trainee) { create(:trainee, :future) }

    before do
      current_trainee
      past_trainee
      future_trainee
    end

    it "is expected to call Trainee::SetCohort on current and future trainees" do
      expect(SetCohortJob).to receive(:perform_later).once.with(current_trainee)
      expect(SetCohortJob).to receive(:perform_later).once.with(future_trainee)
      expect(SetCohortJob).not_to receive(:perform_later).with(past_trainee)

      described_class.perform_now
    end
  end
end
