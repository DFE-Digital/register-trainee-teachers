# frozen_string_literal: true

require "rails_helper"

module Dqt
  describe UpdateTraineeJob do
    before do
      enable_features(:integrate_with_dqt)
      allow(Dqt::TraineeUpdate).to receive(:call).with(trainee: trainee)
    end

    context "with valid state trainee" do
      let(:trainee) { create(:trainee, :trn_received) }

      it "calls the TraineeUpdate service" do
        described_class.perform_now(trainee)

        expect(Dqt::TraineeUpdate).to have_received(:call).with(trainee: trainee)
      end
    end

    %i[draft recommended_for_award withdrawn awarded].each do |state|
      context "with a #{state} trainee" do
        let(:trainee) { create(:trainee, state) }

        it "does not call the TraineeUpdate service" do
          described_class.perform_now(trainee)

          expect(Dqt::TraineeUpdate).not_to have_received(:call).with(trainee: trainee)
        end
      end
    end
  end
end
