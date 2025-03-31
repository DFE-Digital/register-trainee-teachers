# frozen_string_literal: true

require "rails_helper"

describe "`POST /trainees/:trainee_slug/placements/` endpoint" do
  context "with a valid authentication token" do
    let(:provider) { trainee.provider }
    let(:token) { AuthenticationToken.create_with_random_token(provider: provider, name: "test token", created_by: provider.users.first).token }
    let(:trainee_slug) { trainee.slug }
    let(:trainee) { create(:trainee) }
    let(:placement_attribute_keys) { Api::V01::PlacementAttributes::ATTRIBUTES }

    context "with a valid trainee and placement" do
      context "create placement with a school" do
        let(:school) { create(:school) }
        let(:data) { { urn: school.urn } }
        let(:params) do
          { data: }.with_indifferent_access
        end

        it "creates a new placement and returns a 201 (created) status" do
          expect {
            post "/api/v0.1/trainees/#{trainee_slug}/placements", params: params.to_json, headers: { Authorization: token, **json_headers }
          }.to change {
            trainee.placements.count
          }.from(0).to(1)

          expect(response).to have_http_status(:created)
          expect(response.parsed_body[:data]).to include(data)

          placement = trainee.placements.take

          expect(placement.urn).to eq(school.urn)
          expect(placement.school_id).to eq(school.id)
          expect(placement.address).to be_nil
          expect(placement.name).to eq(school.name)
          expect(placement.postcode).to eq(school.postcode)
        end

        it "updates the progress attribute on the trainee" do
          post "/api/v0.1/trainees/#{trainee_slug}/placements", params: params.to_json, headers: { Authorization: token, **json_headers }

          expect(trainee.reload.progress[:placements]).to be(true)
        end
      end

      context "create placement without a school" do
        let(:data) { attributes_for(:placement).slice(*placement_attribute_keys) }
        let(:params) do
          { data: }.with_indifferent_access
        end

        it "creates a new placement and returns a 201 (created) status" do
          expect {
            post "/api/v0.1/trainees/#{trainee_slug}/placements", params: params.to_json, headers: { Authorization: token, **json_headers }
          }.to change {
            trainee.placements.count
          }.from(0).to(1)

          placement = trainee.reload.placements.take

          expect(response).to have_http_status(:created)
          expect(response.parsed_body["data"]).to include(
            urn: data[:urn],
            name: data[:name],
            address: "URN #{data[:urn]}, #{data[:postcode]}",
            postcode: data[:postcode],
            placement_id: placement.slug,
          )

          expect(placement.school_id).to be_nil
          expect(placement.urn).to eq(data[:urn])
          expect(placement.address).to eq(data[:address])
          expect(placement.name).to eq(data[:name])
          expect(placement.postcode).to eq(data[:postcode])
        end

        context "with different trainee" do
          let(:trainee_for_another_provider) { create(:trainee) }
          let(:trainee_slug) { trainee_for_another_provider.slug }
          let(:data) { attributes_for(:placement).slice(*placement_attribute_keys) }
          let(:params) do
            { data: }.with_indifferent_access
          end

          it "does not create a new placement and returns a 404 status (not_found) status" do
            expect {
              post "/api/v0.1/trainees/#{trainee_slug}/placements", params: params.to_json, headers: { Authorization: token, **json_headers }
            }.not_to change {
              trainee.placements.count
            }

            expect(response).to have_http_status(:not_found)
          end
        end

        context "with an invalid placement attributes" do
          let(:params) do
            { data: Api::V01::PlacementAttributes::ATTRIBUTES.index_with { |_| nil } }
          end

          it "does not create a new placements and returns a 422 status (unprocessable_entity) status" do
            expect {
              post "/api/v0.1//trainees/#{trainee_slug}/placements", params: params.to_json, headers: { Authorization: token, **json_headers }
            }.not_to change {
              trainee.placements.count
            }

            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.parsed_body["errors"]).to contain_exactly(
              error: "UnprocessableEntity",
              message: "Name can't be blank",
            )
          end
        end
      end

      context "with a duplicate placement" do
        let(:params) do
          { data: }.with_indifferent_access
        end
        let(:trainee) { existing_placement.trainee }

        context "with a school" do
          let(:existing_placement) { create(:placement, :with_school) }
          let(:school) { existing_placement.school }
          let(:data) { { urn: school.urn } }

          it "creates a new placement and returns a 201 (created) status" do
            expect {
              post "/api/v0.1/trainees/#{trainee_slug}/placements", params: params.to_json, headers: { Authorization: token, **json_headers }
            }.to change {
              trainee.placements.count
            }.from(1).to(2)

            expect(response).to have_http_status(:created)
            expect(response.parsed_body[:data]).to include(data)

            placement = trainee.placements.last

            expect(placement.urn).to eq(school.urn)
            expect(placement.school_id).to eq(school.id)
            expect(placement.address).to be_nil
            expect(placement.name).to eq(school.name)
            expect(placement.postcode).to eq(school.postcode)
          end
        end

        context "without a school" do
          let(:existing_placement) { create(:placement, address: Faker::Address.street_address) }

          let(:data) { attributes_for(:placement).slice(*placement_attribute_keys) }

          it "creates a new placement and returns a 201 (created) status" do
            expect {
              post "/api/v0.1/trainees/#{trainee_slug}/placements", params: params.to_json, headers: { Authorization: token, **json_headers }
            }.to change {
              trainee.placements.count
            }.from(1).to(2)

            placement = trainee.reload.placements.order(:id).last

            expect(response).to have_http_status(:created)
            expect(response.parsed_body["data"]).to include(
              urn: data[:urn],
              name: data[:name],
              address: "URN #{data[:urn]}, #{data[:postcode]}",
              postcode: data[:postcode],
              placement_id: placement.slug,
            )

            expect(placement.school_id).to be_nil
            expect(placement.urn).to eq(data[:urn])
            expect(placement.address).to eq(data[:address])
            expect(placement.name).to eq(data[:name])
            expect(placement.postcode).to eq(data[:postcode])
          end
        end
      end
    end
  end
end
