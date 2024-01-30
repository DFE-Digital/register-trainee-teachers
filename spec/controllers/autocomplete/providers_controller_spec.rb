# frozen_string_literal: true

require "rails_helper"

module Autocomplete
  describe ProvidersController do
    describe "#index" do
      context "default response" do
        before do
          create(:provider)
          get :index
        end

        it "is successful" do
          expect(response).to have_http_status(:success)
        end

        it "returns a list of providers" do
          expect(json_response["providers"].size).to eq(1)
        end
      end

      context "querying" do
        context "invalid query" do
          before do
            get :index, params: { query: "d" }
          end

          it "returns an error response" do
            expect(response).to have_http_status(:bad_request)
          end
        end

        context "valid query" do
          let(:provider) { create(:provider) }
          let(:provider2) { create(:provider, name: "some other name") }

          before do
            get :index, params: { query: provider.name }
          end

          it "returns the providers matching the query" do
            expect(json_response["providers"]).to match([provider.as_json(only: %i[id name code ukprn])])
          end
        end
      end

      context "limiting" do
        before do
          create_list(:provider, 2)
          get :index, params: { limit: 1 }
        end

        it "limits the results based on the provided limit" do
          expect(json_response["providers"].size).to eq(1)
        end
      end
    end
  end
end
