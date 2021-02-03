# frozen_string_literal: true

require "rails_helper"

describe Trainees::QtsRecommendationsController do
  include ActiveJob::TestHelper

  let(:current_user) { create(:user) }
  let(:trainee) { create(:trainee, :trn_received, provider: current_user.provider) }

  before do
    allow(controller).to receive(:current_user).and_return(current_user)
  end

  describe "#create" do
    it "it updates the placement assignment in DTTP to mark it ready for QTS" do
      expect {
        post :create, params: { trainee_id: trainee }
      }.to have_enqueued_job(RecommendForQtsJob).with(trainee.id)
    end

    it "queues a background job to poll for the trainee's QTS" do
      Timecop.freeze(Time.zone.now) do
        expect {
          post :create, params: { trainee_id: trainee }
        }.to have_enqueued_job(RetrieveQtsJob).at(RetrieveQtsJob::POLL_DELAY.from_now).with(trainee.id)
      end
    end

    it "redirects user to the recommended page" do
      post :create, params: { trainee_id: trainee }
      expect(response).to redirect_to(recommended_trainee_outcome_details_path(trainee))
    end

    context "trainee state" do
      before do
        post :create, params: { trainee_id: trainee }
      end

      it "transitions the trainee state to recommended_for_qts" do
        expect(trainee.reload).to be_recommended_for_qts
      end
    end
  end
end
