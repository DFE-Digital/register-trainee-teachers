require "rails_helper"

describe TrnSubmissionsController do
  describe "#create" do
    let(:trainee_id) { "10" }

    it "passes the trainee to the create service" do
      allow(Trainee).to receive(:find).with(trainee_id).and_return(trainee = instance_double(Trainee))
      expect(Dttp::ContactService::Create).to receive(:call).with(trainee: trainee)

      post :create, params: { trainee_id: trainee_id }
    end
  end
end
