# frozen_string_literal: true

require "rails_helper"

describe "authentication" do
  context "attempting to visit a restricted page" do
    context "without been authenticated" do
      it "redirects back to the sign in page" do
        get trainees_path
        expect(response).to redirect_to(sign_in_path)
      end
    end
  end

  context "attempting to visit a public path" do
    it "does not require basic auth" do
      get "/metrics"
      expect(response).to have_http_status(:ok)
    end
  end
end
