# frozen_string_literal: true

require "rails_helper"

describe "Placement address in API v2027.0" do
  let(:trainee) { create(:trainee, :trn_received) }
  let(:token) { create(:authentication_token, provider: trainee.provider).token }
  let(:headers) { { Authorization: token, **json_headers } }
  let(:endpoint) { "/api/v2027.0/trainees/#{trainee.slug}/placements" }
  let(:address) do
    {
      name: "Little Acorns Day Nursery",
      address_line_one: "14 Mill Lane",
      address_line_two: "Headington",
      town_city: "Oxford",
      postcode: "OX3 9DU",
    }
  end

  describe "POST" do
    it "saves the address of a school or setting that is not listed" do
      post endpoint, params: { data: address }.to_json, headers: headers

      expect(response).to have_http_status(:created)
      expect(response.parsed_body[:data]).to include(
        name: "Little Acorns Day Nursery",
        address: "14 Mill Lane, Headington, Oxford, OX3 9DU",
        address_line_one: "14 Mill Lane",
        address_line_two: "Headington",
        town_city: "Oxford",
        postcode: "OX3 9DU",
      )

      placement = trainee.placements.take
      expect(placement.address).to eq("14 Mill Lane\nHeadington\nOxford")
    end

    it "accepts a placement without an address" do
      post endpoint, params: { data: { name: "Little Acorns Day Nursery" } }.to_json, headers: headers

      expect(response).to have_http_status(:created)
      expect(response.parsed_body[:data]).to include(address_line_one: nil, address_line_two: nil, town_city: nil)
      expect(trainee.placements.take.address).to be_nil
    end

    it "ignores the address when the URN matches a listed school" do
      school = create(:school)

      post endpoint, params: { data: address.merge(urn: school.urn) }.to_json, headers: headers

      expect(response).to have_http_status(:created)
      placement = trainee.placements.take
      expect(placement.school).to eq(school)
      expect(placement.address).to be_nil
    end

    it "rejects an address line that is too long" do
      post endpoint, params: { data: address.merge(address_line_one: "a" * 256) }.to_json, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(trainee.placements.count).to eq(0)
    end
  end

  describe "PUT" do
    let!(:placement) do
      create(:placement, trainee: trainee, name: "Little Acorns Day Nursery", urn: nil,
                         address: "14 Mill Lane\nHeadington\nOxford", postcode: "OX3 9DU")
    end

    it "changes one line and keeps the others" do
      put "#{endpoint}/#{placement.slug}", params: { data: { town_city: "Abingdon" } }.to_json, headers: headers

      expect(response).to have_http_status(:ok)
      expect(placement.reload.address).to eq("14 Mill Lane\nHeadington\nAbingdon")
      expect(response.parsed_body[:data]).to include(address: "14 Mill Lane, Headington, Abingdon, OX3 9DU")
    end
  end

  describe "GET" do
    let!(:placement) do
      create(:placement, trainee: trainee, name: "Little Acorns Day Nursery", urn: nil,
                         address: "14 Mill Lane\n\nOxford", postcode: "OX3 9DU")
    end

    it "returns each address line" do
      get("#{endpoint}/#{placement.slug}", headers:)

      expect(response.parsed_body[:data]).to include(
        address: "14 Mill Lane, Oxford, OX3 9DU",
        address_line_one: "14 Mill Lane",
        address_line_two: nil,
        town_city: "Oxford",
      )
    end

    it "does not return the address lines in v2026.1" do
      get("/api/v2026.1/trainees/#{trainee.slug}/placements/#{placement.slug}", headers:)

      expect(response.parsed_body[:data]).to include(address: "14 Mill Lane, Oxford, OX3 9DU")
      expect(response.parsed_body[:data].keys).not_to include("address_line_one", "town_city")
    end
  end
end
