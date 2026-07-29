# frozen_string_literal: true

require "rails_helper"

describe "`GET /trainees/:trainee_slug/degrees/:slug` endpoint" do
  context "with a valid authentication token" do
    let(:provider) { trainee.provider }
    let(:token) { create(:authentication_token, provider:).token }
    let(:trainee_slug) { trainee.slug }
    let(:slug) { trainee.degrees.last.slug }
    let(:trainee) { create(:trainee, :with_degree) }

    context "with a valid trainee that has a degree" do
      it "returns status code 200 with a valid JSON response" do
        get "/api/v2026.1//trainees/#{trainee_slug}/degrees/#{slug}", headers: { Authorization: token }
        expect(response).to have_http_status(:ok)
      end
    end

    context "with a subject label that shares a HESA code" do
      let(:trainee) { create(:trainee) }
      let!(:degree) { create(:degree, :uk_degree_type, trainee: trainee, subject: subject_name) }
      let(:slug) { degree.slug }

      before { get "/api/v2026.1//trainees/#{trainee_slug}/degrees/#{slug}", headers: { Authorization: token } }

      context "with the canonical label" do
        let(:subject_name) { "Computing" }

        it "serializes the subject as its HESA code" do
          expect(response.parsed_body.dig(:data, :subject)).to eq("100367")
        end
      end

      context "with the superseded alias label" do
        let(:subject_name) { "Computing and information technology" }

        it "serializes the subject as the same HESA code" do
          expect(response.parsed_body.dig(:data, :subject)).to eq("100367")
        end
      end
    end

    context "non existant degree" do
      let(:slug) { "non-existant" }

      it "returns status code 404 with a valid JSON response" do
        get "/api/v2026.1//trainees/#{trainee_slug}/degrees/#{slug}", headers: { Authorization: token }

        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body[:errors]).to contain_exactly({ error: "NotFound", message: "Degree(s) not found" })
      end
    end
  end
end
