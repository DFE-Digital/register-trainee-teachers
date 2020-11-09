require "rails_helper"

RSpec.describe SessionsController, type: :controller do
  let(:user_id) { "1" }

  describe "#create" do
    before do
      post :create, params: { user_id: user_id }
    end

    it "creates a session for the persona" do
      expect(session[:auth_user]).to eq({ user_id: user_id })
    end

    it "redirects to the trainees index page" do
      expect(response).to redirect_to(trainees_path)
    end
  end
end
