# frozen_string_literal: true

require "rails_helper"

describe Reports::PlacementsController do
  let!(:current_cycle) { create(:academic_cycle, :current) }
  let(:user) { build_current_user }
  let(:provider) { user.organisation }

  before do
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "#index" do
    let(:trainee) { create(:trainee, :trn_received, provider:) }

    before do
      create(
        :placement,
        trainee: trainee,
        created_at: current_cycle.start_date + 1.day,
      )
    end

    it "returns a CSV with the expected filename" do
      get :index

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq("text/csv; charset=utf-8")
      expect(response.headers["Content-Disposition"]).to include(
        "#{current_cycle.label('-')}-placements-report-",
      )
      expect(response.headers["Content-Disposition"]).to include(".csv")
    end

    it "includes the trainee placement data" do
      get :index

      csv = CSV.parse(response.body, headers: true)
      expect(csv.first["TRN"]).to eq(trainee.trn)
    end
  end
end
