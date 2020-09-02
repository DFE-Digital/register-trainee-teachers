require "rails_helper"

RSpec.describe Trainees::ContactDetailsController do
  describe "#index" do
    let(:trainee) { build(:trainee) }
    let(:id) { "1" }

    before do
      expect(Trainee).to receive(:find).with(id).and_return(trainee)
      get :index, params: { id: id }
    end

    it "returns 200" do
      expect(response).to be_successful
    end
  end
end
