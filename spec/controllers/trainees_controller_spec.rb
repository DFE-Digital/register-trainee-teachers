require "rails_helper"

RSpec.describe TraineesController do
  describe "#show" do
    it "returns 200" do
      get :show, params: { id: 1 }
      expect(response).to be_successful
    end
  end
end
