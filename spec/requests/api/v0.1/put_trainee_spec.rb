# frozen_string_literal: true

require "rails_helper"

describe "`PUT /api/v0.1/trainees/:id` endpoint" do
  let(:trainee) { create(:trainee, :in_progress, :with_hesa_trainee_detail, first_names: "Bob") }
  let(:other_trainee) { create(:trainee, :in_progress, first_names: "Bob") }
  let(:provider) { trainee.provider }

  context "with an invalid authentication token" do
    let(:token) { "not-a-valid-token" }

    it "returns status 401 unauthorized" do
      put(
        "/api/v0.1/trainees/#{trainee.slug}",
        headers: { Authorization: "Bearer #{token}" },
        params: { data: { first_names: "Alice" } },
      )
      expect(response).to have_http_status(:unauthorized)
      expect(trainee.reload.first_names).to eq("Bob")
    end
  end

  context "with an valid authentication token and the feature flag off", feature_register_api: false do
    let(:token) { AuthenticationToken.create_with_random_token(provider:) }

    it "returns status 404 not found" do
      put(
        "/api/v0.1/trainees/#{trainee.slug}",
        headers: { Authorization: "Bearer #{token}" },
        params: { data: { first_names: "Alice" } },
      )
      expect(response).to have_http_status(:not_found)
      expect(trainee.reload.first_names).to eq("Bob")
    end
  end

  context "with a valid authentication token" do
    let(:token) { AuthenticationToken.create_with_random_token(provider:) }

    it "returns status 404 if the trainee does not exist" do
      put(
        "/api/v0.1/trainees/missing-trainee-slug",
        headers: { Authorization: "Bearer #{token}" },
        params: { data: { first_names: "Alice" } },
      )
      expect(response).to have_http_status(:not_found)
    end

    it "returns status 422 if the request body is invalid (not a serialised trainee)" do
      put(
        "/api/v0.1/trainees/#{trainee.slug}",
        headers: { Authorization: "Bearer #{token}" },
        params: { foo: { bar: "Alice" } },
      )
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body[:errors]).to contain_exactly("Param is missing or the value is empty: data")
    end

    it "returns status 422 if the request data is invalid (has an invalid attribute value)" do
      put(
        "/api/v0.1/trainees/#{trainee.slug}",
        headers: { Authorization: "Bearer #{token}" },
        params: { data: { first_names: "Llanfairpwllgwyngyllgogerychwyrdrobwllllantysiliogogogoch", email: "invalid" } },
      )
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body[:errors]).to contain_exactly(
        ["contact_details", { "email" => ["Enter an email address in the correct format, like name@example.com"] }],
        ["personal_details", { "first_names" => ["First name must be 50 characters or fewer"] }],
      )
    end

    it "returns 404 if the trainee does not belong to the authenticated provider" do
      put(
        "/api/v0.1/trainees/#{other_trainee.slug}",
        headers: { Authorization: "Bearer #{token}" },
        params: { data: { first_names: "Alice" } },
      )
      expect(response).to have_http_status(:not_found)
    end

    it "returns status 200 with a valid JSON response" do
      put(
        "/api/v0.1/trainees/#{trainee.slug}",
        headers: { Authorization: "Bearer #{token}" },
        params: { data: { first_names: "Alice", provider_trainee_id: "99157234/2/01" } },
      )
      expect(response).to have_http_status(:ok)
      expect(trainee.reload.first_names).to eq("Alice")
      expect(trainee.provider_trainee_id).to eq("99157234/2/01")
      expect(response.parsed_body[:data]["trainee_id"]).to eq(trainee.slug)
    end

    it "returns status 200 and updates nationality" do
      create(:nationality, :irish)
      put(
        "/api/v0.1/trainees/#{trainee.slug}",
        headers: { Authorization: "Bearer #{token}" },
        params: { data: { nationality: "IE" } },
      )
      expect(response).to have_http_status(:ok)
      expect(trainee.reload.nationalities.first.name).to eq("irish")
    end
  end
end
