# frozen_string_literal: true

require "rails_helper"

describe ReportsController do
  let(:user) { build_current_user }

  before do
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "#index" do
    it "returns a 200 status code" do
      get :index
      expect(response).to have_http_status(:ok)
    end

    it "renders the application template" do
      get :index
      expect(response).to render_template("application")
    end
  end

  describe "#itt_new_starter_data_sign_off" do
    before do
      create(:academic_cycle, :current)
    end

    it "returns a 200 status code" do
      get :itt_new_starter_data_sign_off
      expect(response).to have_http_status(:ok)
    end

    it "renders the application template" do
      get :itt_new_starter_data_sign_off
      expect(response).to render_template("application")
    end

    it "renders a csv" do
      get :itt_new_starter_data_sign_off, params: { format: :csv }
      expect(response.content_type).to eq("text/csv")
    end
  end
end
