# frozen_string_literal: true

require "rails_helper"

describe Reports::CensusesController do
  let(:user) { build_current_user }
  let(:academic_cycle) { create(:academic_cycle, previous_cycle: false) }

  before do
    academic_cycle
    allow(controller).to receive(:current_user).and_return(user)
    allow(DetermineSignOffPeriod).to receive(:call).and_return(:census_period)
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

    context "csv export" do
      it "uses the second wednesday of october as the census date" do
        expect(FindNewStarterTrainees).to receive(:new)
          .with(academic_cycle.second_wednesday_of_october)
          .and_call_original

        get :index, params: { format: :csv }
      end
    end
  end
end
