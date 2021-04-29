# frozen_string_literal: true

require "rails_helper"

module Api
  describe SchoolsController, type: :controller do
    describe "#index" do
      context "default response" do
        before do
          create(:school)
          get :index
        end

        it "is successful" do
          expect(response).to have_http_status(:success)
        end

        it "returns a list of schools" do
          expect(json_response["schools"].size).to eq(1)
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
          let(:school) { create(:school) }
          let(:school2) { create(:school, name: "some other name") }

          before do
            get :index, params: { query: school.name }
          end

          it "returns the schools matching the query" do
            expect(json_response["schools"]).to match([school.as_json(only: %i[id name])])
          end
        end
      end

      context "limiting" do
        before do
          create_list(:school, 2)
          get :index, params: { limit: 1 }
        end

        it "limits the results based on the provided limit" do
          expect(json_response["schools"].size).to eq(1)
        end
      end

      context "lead schools only" do
        let(:lead_school) { create(:school, lead_school: true) }

        before do
          lead_school
          create(:school)
          get :index, params: { lead_school: true }
        end

        it "returns only lead schools" do
          expect(json_response["schools"]).to match([lead_school.as_json(only: %i[id name])])
        end
      end
    end
  end
end
