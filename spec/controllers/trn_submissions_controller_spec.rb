require "rails_helper"

describe TrnSubmissionsController do
  describe "#create" do
    let(:trainee_id) { "10" }
    let(:trainee_data) { { some: "data" } }
    let(:decorated_trainee) { instance_double(Dttp::TraineePresenter) }

    it "passes the decorated trainee to the create service" do
      allow(Trainee).to receive(:find).with(trainee_id).and_return(trainee = instance_double(Trainee))
      expect(Dttp::TraineePresenter).to receive(:new).with(trainee: trainee).and_return(decorated_trainee)
      expect(Dttp::ContactService::Create).to receive(:call).with(trainee: decorated_trainee)

      post :create, params: { trainee_id: trainee_id }
    end
  end
end
