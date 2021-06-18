# frozen_string_literal: true

require "rails_helper"

describe Trainees::AwardRecommendationsController do
  include ActiveJob::TestHelper

  let(:current_user) { create(:user) }
  let(:trainee) { create(:trainee, :trn_received, provider: current_user.provider) }

  before do
    allow(controller).to receive(:current_user).and_return(current_user)
    allow(OutcomeDateForm).to receive(:new).with(trainee).and_return(double(save!: true))
  end

  describe "#create" do
    it "updates the placement assignment in DTTP to mark it ready for QTS" do
      expect {
        post :create, params: { trainee_id: trainee }
      }.to have_enqueued_job(RecommendForAwardJob).with(trainee)
    end

    it "queues a background job to poll for the trainee's QTS" do
      expect(RetrieveAwardJob).to receive(:perform_with_default_delay).with(trainee)
      post :create, params: { trainee_id: trainee }
    end

    it "redirects user to the recommended page" do
      post :create, params: { trainee_id: trainee }
      expect(response).to redirect_to(recommended_trainee_outcome_details_path(trainee))
    end

    context "trainee state" do
      before do
        post :create, params: { trainee_id: trainee }
      end

      it "transitions the trainee state to recommended_for_award" do
        expect(trainee.reload).to be_recommended_for_award
      end
    end
  end
end
