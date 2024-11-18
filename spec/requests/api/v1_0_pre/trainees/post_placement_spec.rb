# frozen_string_literal: true

require "rails_helper"

describe "`POST /trainees/:trainee_slug/placements/` endpoint" do
  context "with a valid authentication token" do
    let(:provider) { trainee.provider }
    let(:token) { AuthenticationToken.create_with_random_token(provider:) }
    let(:trainee_slug) { trainee.slug }
    let(:trainee) { create(:trainee) }
    let(:placement_attribute_keys) { Api::V10Pre::PlacementAttributes::ATTRIBUTES.map(&:to_s) }

    context "with a valid trainee and placement" do
      context "create placement with a school" do
        let(:school) { create(:school) }
        let(:params) do
          { data: { urn: school.urn } }.with_indifferent_access
        end

        it "creates a new placement and returns a 201 (created) status" do
          expect {
            post "/api/v1.0-pre/trainees/#{trainee_slug}/placements", params: params.to_json, headers: { Authorization: token, **json_headers }
          }.to change {
            trainee.placements.count
          }.from(0).to(1)

          expect(response).to have_http_status(:created)
          expect(response.parsed_body["data"]).to be_present
          expect(response.parsed_body["data"]).to include(
            urn: school.urn,
            name: school.name,
            postcode: school.postcode,
          )

          placement = trainee.placements.take

          expect(placement.urn).to eq(school.urn)
          expect(placement.school_id).to eq(school.id)
          expect(placement.address).to be_nil
          expect(placement.name).to eq(school.name)
          expect(placement.postcode).to eq(school.postcode)
        end

        context "with different trainee" do
          let(:trainee_for_another_provider) { create(:trainee) }
          let(:trainee_slug) { trainee_for_another_provider.slug }
          let(:params) do
            { data: create(:placement).attributes.slice(*placement_attribute_keys) }.with_indifferent_access
          end

          it "does not create a new placement and returns a 422 status (unprocessable_entity) status" do
            expect {
              post "/api/v1.0-pre/trainees/#{trainee_slug}/placements", params: params.to_json, headers: { Authorization: token, **json_headers }
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
              post "/api/v1.0-pre/trainees/#{trainee_slug}/placements", params: params.to_json, headers: { Authorization: token, **json_headers }
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

      context "create placement without a school" do
        let(:data) { attributes_for(:placement).except(:urn).with_indifferent_access.slice(*placement_attribute_keys) }
        let(:params) do
          { data: }.with_indifferent_access
        end

        it "creates a new placement and returns a 201 (created) status" do
          expect {
            post "/api/v1.0-pre//trainees/#{trainee_slug}/placements", params: params.to_json, headers: { Authorization: token, **json_headers }
          }.to change {
            trainee.placements.count
          }.from(0).to(1)

          placement = trainee.placements.take

          expect(response).to have_http_status(:created)
          expect(response.parsed_body[:data]).to include(
            urn: nil,
            name: data[:name],
            address: placement.full_address,
            postcode: data[:postcode],
            placement_id: placement.slug,
          )

          expect(placement.school_id).to be_nil
          expect(placement.urn).to be_nil
          expect(placement.address).to be_nil
          expect(placement.name).to eq(data[:name])
          expect(placement.postcode).to eq(data[:postcode])
        end

        it "updates the progress attribute on the trainee" do
          post "/api/v1.0-pre//trainees/#{trainee_slug}/placements", params: params.to_json, headers: { Authorization: token, **json_headers }

          expect(trainee.reload.progress[:placements]).to be(true)
        end
      end
    end
  end
end
