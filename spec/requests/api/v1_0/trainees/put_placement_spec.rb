# frozen_string_literal: true

require "rails_helper"

describe "`PUT /trainees/:trainee_slug/placements/:slug` endpoint" do
  context "with a valid authentication token" do
    let(:provider) { trainee.provider }
    let(:token) { AuthenticationToken.create_with_random_token(provider:) }
    let(:trainee_slug) { trainee.slug }
    let(:trainee) { create(:trainee, :with_placements) }
    let(:placement) { trainee.placements.first }
    let(:slug) { placement.slug }
    let(:placement_attribute_keys) { Api::V10::PlacementAttributes::ATTRIBUTES.map(&:to_s) }

    context "with a valid trainee and placement" do
      context "update placement with school_id" do
        let(:params) do
          { data: create(:placement).attributes.slice(*placement_attribute_keys) }.with_indifferent_access
        end

        it "updates an existing placement and returns a 200 (ok) status" do
          put "/api/v1.0//trainees/#{trainee_slug}/placements/#{slug}", params: params.to_json, headers: { Authorization: token, **json_headers }

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body["data"]["placement_id"]).to eql(slug)
          expect(trainee.reload.placements.count).to eq(2)

          expect(placement.reload.school_id).to eq(params.dig(:data, :school_id))
          expect(placement.reload.address).to be_blank
          expect(placement.reload.name).to eq(School.find(params.dig(:data, :school_id)).name)
          expect(placement.reload.postcode).to be_blank
          expect(placement.reload.urn).to be_blank
        end
      end

      context "updates an existing placement without school_id" do
        let(:params) do
          { data: create(:placement, :manual).attributes.slice(*placement_attribute_keys) }.with_indifferent_access
        end

        let(:params_to_update_postcode) do
          { data: { postcode: "GU1 1AA" }.with_indifferent_access }
        end

        it "creates a new placement and returns a 200 (ok) status" do
          put "/api/v1.0//trainees/#{trainee_slug}/placements/#{slug}", params: params.to_json, headers: { Authorization: token, **json_headers }

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body["data"]["placement_id"]).to eql(slug)
          expect(trainee.reload.placements.count).to eq(2)

          expect(placement.reload.school_id).to be_blank
          expect(placement.reload.address).to eq(params.dig(:data, :address))
          expect(placement.reload.name).to eq(params.dig(:data, :name))
          expect(placement.reload.postcode).to eq(params.dig(:data, :postcode))
          expect(placement.reload.urn).to eq(params.dig(:data, :urn))
        end

        it "partial update of an existing placement returns 200 (ok) status" do
          put "/api/v1.0//trainees/#{trainee_slug}/placements/#{slug}", params: params_to_update_postcode.to_json, headers: { Authorization: token, **json_headers }

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body["data"]["placement_id"]).to eql(slug)
          expect(trainee.reload.placements.count).to eq(2)

          expect(placement.reload.postcode).to eq("GU1 1AA")
        end

        context "with different trainee" do
          let(:trainee_for_another_provider) { create(:trainee) }
          let(:trainee_slug) { trainee_for_another_provider.slug }
          let(:params) do
            { data: create(:placement).attributes.slice(*placement_attribute_keys) }.with_indifferent_access
          end

          it "does not create a new placement and returns a 422 status (unprocessable_entity) status" do
            put "/api/v1.0//trainees/#{trainee_slug}/placements/#{slug}", params: params.to_json, headers: { Authorization: token, **json_headers }

            expect(response).to have_http_status(:not_found)
            expect(trainee.reload.placements.count).to eq(2)
          end
        end

        context "with an invalid placement attributes" do
          let(:params) do
            { data: Api::V10::PlacementAttributes::ATTRIBUTES.index_with { |_| nil } }
          end

          it "does not create a new placements and returns a 422 status (unprocessable_entity) status" do
            put "/api/v1.0//trainees/#{trainee_slug}/placements/#{slug}", params: params.to_json, headers: { Authorization: token, **json_headers }

            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.parsed_body["errors"].count).to eq(2)
            expect(trainee.reload.placements.count).to eq(2)
          end
        end
      end
    end
  end
end
