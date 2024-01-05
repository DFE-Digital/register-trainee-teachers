# frozen_string_literal: true

require "rails_helper"

describe ErrorsController do
  describe "GET #not_found" do
    it "returns not found" do
      get :not_found
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET #internal_server_error" do
    it "returns internal_server_error" do
      get :internal_server_error
      expect(response).to have_http_status(:internal_server_error)
    end
  end

  describe "GET #unprocessable_entity" do
    it "returns unprocessable_entity" do
      get :unprocessable_entity
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "flash messages" do
    it "removes any flash messages" do
      %i[not_found internal_server_error unprocessable_entity].each do |action|
        get action, flash: { success: "Success" }
        expect(flash[:success]).not_to be_present
      end
    end
  end
end
