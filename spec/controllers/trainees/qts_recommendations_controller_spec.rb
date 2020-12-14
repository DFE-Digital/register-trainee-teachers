# frozen_string_literal: true

require "rails_helper"

describe Trainees::QtsRecommendationsController do
  include ActiveJob::TestHelper

  let(:trainee) { create(:trainee) }
  let(:current_user) { build(:user) }
  let(:trainee_policy) { instance_double(TraineePolicy, create?: true) }

  before do
    allow(controller).to receive(:current_user).and_return(current_user)
    allow(TraineePolicy).to receive(:new).with(current_user, trainee).and_return(trainee_policy)
  end

  describe "#create" do
    it "it updates the placement assignment in DTTP to mark it ready for QTS" do
      expect {
        post :create, params: { trainee_id: trainee.id }
      }.to have_enqueued_job(RecommendForQtsJob).with(trainee.id)
    end

    it "redirects user to the recommended page" do
      post :create, params: { trainee_id: trainee.id }
      expect(response).to redirect_to(recommended_trainee_outcome_details_path(trainee_id: trainee.id))
    end
  end
end
