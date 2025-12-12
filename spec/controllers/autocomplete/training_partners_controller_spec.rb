# frozen_string_literal: true

require "rails_helper"

module Autocomplete
  describe TrainingPartnersController do
    describe "#index" do
      let(:json_response) { response.parsed_body }

      context "default response" do
        before do
          create(:training_partner, :hei)
          get :index
        end

        it "is successful" do
          expect(response).to have_http_status(:success)
        end

        it "returns a list of training_partners" do
          expect(json_response["training_partners"].size).to eq(1)
        end
      end

      context "querying" do
        let!(:training_partner) { create(:training_partner, :school, name: "Sheffield School") }
        let!(:training_partner2) { create(:training_partner, :school, name: "Cardiff College") }
        let!(:training_partner_hei) { create(:training_partner, :hei, name: "Newbury University") }

        context "invalid query" do
          before do
            get :index, params: { query: "d" }
          end

          it "returns an error response" do
            expect(response).to have_http_status(:bad_request)
          end
        end

        context "valid query by name" do
          before do
            get :index, params: { query: training_partner.name }
          end

          it "returns the training_partners matching the query only" do
            expect(json_response["training_partners"]).to match([training_partner.as_json(only: %i[id name urn ukprn])])
          end
        end

        context "valid query by urn" do
          before do
            get :index, params: { query: training_partner.urn }
          end

          it "returns the training_partners matching the query only" do
            expect(json_response["training_partners"]).to match([training_partner.as_json(only: %i[id name urn ukprn])])
          end
        end

        context "valid query by ukprn" do
          before do
            get :index, params: { query: training_partner_hei.ukprn }
          end

          it "returns the training_partners matching the query only" do
            expect(json_response["training_partners"]).to match([training_partner_hei.as_json(only: %i[id name urn ukprn])])
          end
        end
      end

      context "limiting" do
        before do
          create_list(:training_partner, 3, :hei)
          get :index, params: { limit: 2 }
        end

        it "limits the results based on the provided limit" do
          expect(json_response["training_partners"].size).to eq(2)
        end
      end
    end
  end
end
