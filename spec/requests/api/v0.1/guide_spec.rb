# frozen_string_literal: true

require "rails_helper"

describe "guidance endpoint" do
  context "visiting" do
    it "returns status 200" do
      get "/api/v0.1/guide"
      expect(response).to have_http_status(:ok)
    end
  end
end
