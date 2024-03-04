# frozen_string_literal: true

require "rails_helper"

describe "`POST /trainees/:trainee_slug/placements/` endpoint" do
  context "with a valid authentication token" do
    let(:provider) { trainee.provider }
    let(:token) { AuthenticationToken.create_with_random_token(provider:) }
    let(:trainee_slug) { trainee.slug }
    let(:trainee) { create(:trainee) }
    let(:placement_attribute_keys) { Api::PlacementAttributes::V01::ATTRIBUTES.map(&:to_s) }

    context "with a valid trainee and placement" do
      context "create placement with school_id" do
        let(:params) do
          { data: create(:placement).attributes.slice(*placement_attribute_keys) }.with_indifferent_access
        end

        it "creates a new placement and returns a 201 (created) status" do
          api_post(0.1, "/trainees/#{trainee_slug}/placements", token:, params:)

          expect(response).to have_http_status(:created)
          expect(response.parsed_body["data"]).to be_present
          expect(trainee.reload.placements.count).to eq(1)

          expect(trainee.reload.placements.first.school_id).to eq(params.dig(:data, :school_id))
          expect(trainee.reload.placements.first.address).to be_blank
          expect(trainee.reload.placements.first.name).to eq(School.find(params.dig(:data, :school_id)).name)
          expect(trainee.reload.placements.first.postcode).to be_blank
          expect(trainee.reload.placements.first.urn).to be_blank
        end

        it "updates the progress attribute on the trainee" do
          api_post(0.1, "/trainees/#{trainee_slug}/placements", token:, params:)
          expect(trainee.reload.progress[:placements]).to be(true)
        end
      end

      context "create placement without school_id" do
        let(:params) do
          { data: create(:placement, :manual).attributes.slice(*placement_attribute_keys) }.with_indifferent_access
        end

        it "creates a new placement and returns a 201 (created) status" do
          api_post(0.1, "/trainees/#{trainee_slug}/placements", token:, params:)

          expect(response).to have_http_status(:created)
          expect(response.parsed_body["data"]).to be_present

          expect(trainee.reload.placements.count).to eq(1)
          expect(trainee.reload.placements.first.school_id).to be_blank
          expect(trainee.reload.placements.first.address).to eq(params.dig(:data, :address))
          expect(trainee.reload.placements.first.name).to eq(params.dig(:data, :name))
          expect(trainee.reload.placements.first.postcode).to eq(params.dig(:data, :postcode))
          expect(trainee.reload.placements.first.urn).to eq(params.dig(:data, :urn))
        end

        context "with different trainee" do
          let(:trainee_for_another_provider) { create(:trainee) }
          let(:trainee_slug) { trainee_for_another_provider.slug }
          let(:params) do
            { data: create(:placement).attributes.slice(*placement_attribute_keys) }.with_indifferent_access
          end

          it "does not create a new placement and returns a 422 status (unprocessable_entity) status" do
            api_post(0.1, "/trainees/#{trainee_slug}/placements", token:, params:)

            expect(response).to have_http_status(:not_found)
            expect(trainee.reload.placements.count).to eq(0)
          end
        end

        context "with an invalid placement attributes" do
          let(:params) do
            { data: Api::PlacementAttributes::V01::ATTRIBUTES.index_with { |_| nil } }
          end

          it "does not create a new placements and returns a 422 status (unprocessable_entity) status" do
            api_post(0.1, "/trainees/#{trainee_slug}/placements", token:, params:)

            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.parsed_body["errors"].count).to eq(2)
            expect(trainee.reload.placements.count).to eq(0)
          end
        end
      end
    end
  end
end
