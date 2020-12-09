# frozen_string_literal: true

require "rails_helper"

describe TrnSubmissionsController do
  include ActiveJob::TestHelper

  describe "#create" do
    let(:trainee) { create(:trainee) }
    let(:current_user) { build(:user) }
    let(:trainee_policy) { instance_double(TraineePolicy, create?: true) }

    before do
      allow(controller).to receive(:current_user).and_return(current_user)
      allow(TraineePolicy).to receive(:new).with(current_user, trainee).and_return(trainee_policy)
    end

    it "launches CreateJob" do
      expect {
        post :create, params: { trainee_id: trainee.id }
      }.to have_enqueued_job(Dttp::CreateJob).with(trainee.id, current_user.dttp_id)
    end
  end
end
