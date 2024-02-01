# frozen_string_literal: true

require 'rails_helper'

describe "GET /trainees", type: :request, feature_register_api: true do
  it_behaves_like "a register API endpoint", "/api/v0.1/trainees"

  let!(:provider) { create(:provider) }
  let!(:academic_cycle) { create(:academic_cycle) }
  let!(:trainees) { create_list(:trainee, 10, provider: provider, start_academic_cycle: academic_cycle) }

  context "filtering by academic cycle" do
    it "returns trainees for the specified academic cycle" do
      api_get 0.1, :trainees, params: { academic_cycle: academic_cycle.start_year }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["trainees"].count).to eq(trainees.count)
    end
  end

  context "filtering by 'since' date" do
    it "returns trainees updated after the specified date" do
      trainees.first(5).each { |t| t.touch(:updated_at) }
      since_date = 1.day.ago.to_date

      api_get 0.1, :trainees, params: { since: since_date }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["trainees"].count).to be >= 5
    end
  end

  context "with pagination parameters" do
    let(:per_page){ 5 }
    it "paginates the results according to 'page' and 'per_page' parameters" do
      api_get 0.1, :trainees, params: { page: 1, per_page: per_page }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["trainees"].count).to eq(per_page)
      expect(response.parsed_body["metadata"]["total_count"]).to eq(trainees.count)
    end
  end
end
