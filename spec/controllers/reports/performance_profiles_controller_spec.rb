# frozen_string_literal: true

require "rails_helper"

describe Reports::PerformanceProfilesController do
  let(:user) { build_current_user }

  before do
    create(:academic_cycle, previous_cycle: true)
    allow(controller).to receive(:current_user).and_return(user)
    allow(DetermineSignOffPeriod).to receive(:call).and_return(:performance_period)
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

    it "renders a csv" do
      get :index, params: { format: :csv }
      expect(response.content_type).to eq("text/csv; charset=utf-8")
    end
  end
end
