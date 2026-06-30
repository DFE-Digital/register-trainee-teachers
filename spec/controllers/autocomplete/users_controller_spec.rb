# frozen_string_literal: true

require "rails_helper"

module Autocomplete
  describe UsersController do
    describe "#index" do
      let(:json_response) { response.parsed_body }

      context "when the user is not a system admin" do
        let(:user) { build_current_user(user: create(:user, :hei)) }

        before do
          allow(controller).to receive(:current_user).and_return(user)

          get :index
        end

        it "returns forbidden" do
          expect(response).to have_http_status(:forbidden)
        end
      end

      context "when the user is a system admin" do
        let(:user) { build_current_user(user: create(:user, :system_admin)) }

        before do
          create(:user)
          allow(controller).to receive(:current_user).and_return(user)

          get :index
        end

        it "is successful" do
          expect(response).to have_http_status(:success)
        end

        it "returns a list of users" do
          expect(json_response["users"].size).to eq(2)
        end
      end
    end
  end
end
