# frozen_string_literal: true

require "rails_helper"

describe "Trainees API" do
  describe "GET /api/v0.1/trainees/:id" do
    let!(:trainee) { create(:trainee, slug: "12345") }

    before do
      allow_any_instance_of(Api::TraineesController).to receive(:current_provider).and_return(trainee.provider)
    end

    it_behaves_like "a register API endpoint", "/api/v0.1/trainees/12345"

    context "when the trainee exists", feature_register_api: true do
      before do
        get "/api/v0.1/trainees/#{trainee.slug}", headers: { Authorization: "Bearer bat" }
      end

      it "returns the trainee" do
        expect(response.parsed_body).to eq(JSON.parse(trainee.to_json))
      end

      it "returns status code 200" do
        expect(response).to have_http_status(:ok)
      end
    end

    context "when the trainee does not exist", feature_register_api: true do
      before do
        get "/api/v0.1/trainees/nonexistent", headers: { Authorization: "Bearer bat" }
      end

      it "returns status code 404" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns a not found message" do
        expect(response.parsed_body["error"]).to eq("Trainee not found")
      end
    end
  end
end