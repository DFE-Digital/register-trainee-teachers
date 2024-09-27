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
    let(:placement_attribute_keys) { Api::V10Pre::PlacementAttributes::ATTRIBUTES.map(&:to_s) }

    context "with a valid trainee and placement" do
      context "update placement with urn" do
        let(:school) { create(:school) }
        let(:params) do
          { data: { urn: school.urn } }.with_indifferent_access
        end

        it "updates an existing placement and returns a 200 (ok) status" do
          expect {
            put "/api/v1.0-pre/trainees/#{trainee_slug}/placements/#{slug}", params: params.to_json, headers: { Authorization: token, **json_headers }
          }.not_to change {
            trainee.placements.count
          }

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body["data"]["placement_id"]).to eql(slug)

          placement.reload

          expect(placement.school_id).to eq(school.id)
          expect(placement.urn).to eq(school.urn)
          expect(placement.address).not_to be_blank
          expect(placement.name).to eq(school.name)
          expect(placement.postcode).to eq(school.postcode)
        end
      end

      context "updates an existing placement without urn" do
        let(:params) do
          { data: create(:placement).attributes.except("urn").slice(*placement_attribute_keys) }.with_indifferent_access
        end

        let(:params_to_update_postcode) do
          { data: { postcode: "GU1 1AA" }.with_indifferent_access }
        end

        it "updates the placement and returns a 200 (ok) status" do
          expect {
            put "/api/v1.0-pre/trainees/#{trainee_slug}/placements/#{slug}", params: params.to_json, headers: { Authorization: token, **json_headers }
          }.not_to change {
            trainee.placements.count
          }

          expect(response).to have_http_status(:ok)

          expect(response.parsed_body["data"]).to include(
            "placement_id" => slug,
            "address" => params.dig(:data, :address),
            "name" => params.dig(:data, :name),
            "postcode" => params.dig(:data, :postcode),
            "urn" => placement.urn,
          )

          placement.reload

          expect(placement.school_id).to eq(placement.school.id)
          expect(placement.address).to eq(params.dig(:data, :address))
          expect(placement.name).to eq(params.dig(:data, :name))
          expect(placement.postcode).to eq(params.dig(:data, :postcode))
          expect(placement.urn).to eq(placement.school.urn)
        end

        it "partial update of an existing placement returns 200 (ok) status" do
          expect {
            put "/api/v1.0-pre/trainees/#{trainee_slug}/placements/#{slug}", params: params_to_update_postcode.to_json, headers: { Authorization: token, **json_headers }
          }.not_to change {
            trainee.placements.count
          }

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body["data"]["placement_id"]).to eql(slug)
          expect(placement.reload.postcode).to eq("GU1 1AA")
        end

        context "with different trainee" do
          let(:trainee_for_another_provider) { create(:trainee) }
          let(:trainee_slug) { trainee_for_another_provider.slug }
          let(:params) do
            { data: create(:placement).attributes.slice(*placement_attribute_keys) }.with_indifferent_access
          end

          it "does not create a new placement and returns a 422 status (unprocessable_entity) status" do
            expect {
              put "/api/v1.0-pre/trainees/#{trainee_slug}/placements/#{slug}", params: params.to_json, headers: { Authorization: token, **json_headers }
            }.not_to change {
              trainee.placements.count
            }

            expect(response).to have_http_status(:not_found)
          end
        end

        context "with an invalid placement attributes" do
          let(:params) do
            { data: Api::V10Pre::PlacementAttributes::ATTRIBUTES.index_with { |_| nil } }
          end

          it "does not create a new placements and returns a 422 status (unprocessable_entity) status" do
            expect {
              put "/api/v1.0-pre/trainees/#{trainee_slug}/placements/#{slug}", params: params.to_json, headers: { Authorization: token, **json_headers }
            }.not_to change {
              trainee.placements.count
            }

            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.parsed_body["errors"]).to contain_exactly(
              "error" => "UnprocessableEntity",
              "message" => "Name can't be blank",
            )
          end
        end
      end
    end
  end
end
