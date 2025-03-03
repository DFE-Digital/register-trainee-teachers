# frozen_string_literal: true

require "rails_helper"

describe "`PUT /trainees/:trainee_slug/placements/:slug` endpoint" do
  context "with a valid authentication token" do
    let(:provider) { trainee.provider }
    let(:token) { AuthenticationToken.create_with_random_token(provider:) }
    let(:trainee) { create(:trainee) }
    let(:trainee_slug) { trainee.slug }
    let(:slug) { placement.slug }
    let(:placement_attribute_keys) { Api::V10Pre::PlacementAttributes::ATTRIBUTES.map(&:to_s) }

    context "with a valid trainee and placement" do
      describe "update placement with a school" do
        let!(:placement) { create(:placement, :with_school, trainee:, school:) }

        let(:school) { create(:school) }

        context "when the params include the school urn" do
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
            expect(response.parsed_body["data"]).to include(
              placement_id: slug,
              urn: school.urn,
              name: school.name,
              postcode: school.postcode,
              address: "URN #{school.urn}, #{school.town}, #{school.postcode}",
            )

            placement.reload

            expect(placement.school_id).to eq(school.id)
            expect(placement.urn).to eq(school.urn)
            expect(placement.name).to eq(school.name)
            expect(placement.postcode).to eq(school.postcode)
            expect(placement.address).to be_blank
          end
        end

        context "when the params do not include the school urn" do
          let(:params) do
            { data: { urn: Faker::Number.unique.number(digits: 6).to_s, name: Faker::University.name } }.with_indifferent_access
          end

          it "updates an existing placement and returns a 200 (ok) status" do
            expect {
              put "/api/v1.0-pre/trainees/#{trainee_slug}/placements/#{slug}", params: params.to_json, headers: { Authorization: token, **json_headers }
            }.not_to change {
              trainee.placements.count
            }

            expect(response).to have_http_status(:ok)

            expect(response.parsed_body["data"]).to include(
              placement_id: slug,
              urn: params.dig(:data, :urn),
              name: params.dig(:data, :name),
              postcode: nil,
              address: "URN #{params.dig(:data, :urn)}",
            )

            placement.reload

            expect(placement.urn).to eq(params.dig(:data, :urn))
            expect(placement.name).to eq(params.dig(:data, :name))
            expect(placement.school_id).to be_nil
            expect(placement.postcode).to be_nil
            expect(placement.address).to be_nil
          end
        end
      end

      describe "updates an existing placement without a school" do
        let!(:placement) { create(:placement, trainee:) }

        let(:params) do
          { data: placement.attributes.except("urn").slice(*placement_attribute_keys) }.with_indifferent_access
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

          placement.reload

          expect(response.parsed_body["data"]).to include(
            placement_id: slug,
            address: placement.full_address,
            name: params.dig(:data, :name),
            postcode: params.dig(:data, :postcode),
            urn: placement.urn,
          )

          expect(placement.school_id).to be_nil
          expect(placement.address).to be_nil
          expect(placement.name).to eq(params.dig(:data, :name))
          expect(placement.postcode).to eq(params.dig(:data, :postcode))
          expect(placement.urn).not_to be_blank
        end

        it "partial update of an existing placement returns status code 200 (ok) status" do
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
      end
    end

    context "with an invalid placement attributes" do
      let!(:placement) { create(:placement, trainee:) }
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

    context "with a duplicate placement" do
      let(:params) do
        { data: }.with_indifferent_access
      end

      context "with a school" do
        let!(:placement) { create(:placement, :with_school, trainee:) }
        let!(:existing_placement) { create(:placement, :with_school, trainee:) }

        let(:data) { { urn: existing_placement.school.urn } }

        it "updates the placement and returns a 200 (ok) status" do
          expect {
            put "/api/v1.0-pre/trainees/#{trainee_slug}/placements/#{slug}", params: params.to_json, headers: { Authorization: token, **json_headers }
          }.not_to change {
            trainee.placements.count
          }

          expect(response).to have_http_status(:ok)

          expect(response.parsed_body["data"]).to include(
            placement_id: slug,
            urn: existing_placement.urn,
            name: existing_placement.name,
            postcode: existing_placement.postcode,
            address: existing_placement.full_address,
          )

          placement.reload

          expect(placement.school_id).to eq(existing_placement.school.id)
          expect(placement.urn).to eq(existing_placement.urn)
          expect(placement.name).to eq(existing_placement.name)
          expect(placement.postcode).to eq(existing_placement.postcode)
          expect(placement.address).to be_blank
        end
      end

      context "without a school" do
        let!(:placement) { create(:placement, trainee:) }
        let!(:existing_placement) { create(:placement, trainee:) }

        let(:params) do
          { data: placement.attributes.except("urn").slice(*placement_attribute_keys) }.with_indifferent_access
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
            "address" => placement.full_address,
            "name" => params.dig(:data, :name),
            "postcode" => params.dig(:data, :postcode),
            "urn" => placement.urn,
          )

          placement.reload

          expect(placement.school_id).to be_nil
          expect(placement.address).to be_nil
          expect(placement.name).to eq(params.dig(:data, :name))
          expect(placement.postcode).to eq(params.dig(:data, :postcode))
          expect(placement.urn).not_to be_blank
        end
      end
    end
  end
end
