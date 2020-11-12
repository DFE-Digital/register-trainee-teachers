# frozen_string_literal: true

require "rails_helper"

describe TrnSubmissionsController do
  describe "#create" do
    let(:trainee) { build(:trainee, provider_id: provider_id) }
    let(:user) { build(:user, provider_id: provider_id) }
    let(:provider_id) { 25 }
    let(:trainee_id) { 10 }
    let(:trainee_data) { { some: "data" } }
    let(:decorated_trainee) { instance_double(Dttp::TraineePresenter, trainee: trainee) }

    before { allow(controller).to receive(:current_user).and_return(user) }

    it "passes the decorated trainee to the create service" do
      allow(Trainee).to receive(:find).with(trainee_id.to_s).and_return(trainee)
      expect(Dttp::TraineePresenter).to receive(:new).with(trainee: trainee).and_return(decorated_trainee)
      expect(Dttp::ContactService::Create).to receive(:call).with(trainee: decorated_trainee)

      post :create, params: { trainee_id: trainee_id }
    end
  end
end
