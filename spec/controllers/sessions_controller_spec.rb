# frozen_string_literal: true

require "rails_helper"

describe SessionsController, type: :controller do
  include DfESignInUserHelper
  let(:user) { create(:user) }
  let(:mocked_auth) { mock_auth(user: user) }
  let(:request_callback) do
    request.env["omniauth.auth"] = mocked_auth
    post :callback
  end

  describe "#callback" do
    context "existing database user" do
      it "creates a session for the signed in user" do
        request_callback
        expect(session[:dfe_sign_in_user]["dfe_sign_in_uid"]).to eq(user.dfe_sign_in_uid)
        expect(session[:dfe_sign_in_user]["email"]).to eq(user.email)

        expect(session[:dfe_sign_in_user]["first_name"]).to eq(user.first_name)
        expect(session[:dfe_sign_in_user]["last_name"]).to eq(user.last_name)
      end

      it "redirects to the trainees index page" do
        request_callback
        expect(response).to redirect_to(trainees_path)
      end
    end

    context "non existing database user" do
      let(:user) { build(:user) }
      it "do not creates a session for the user" do
        request_callback
        expect(session[:dfe_sign_in_user]).to be_nil
      end

      it "redirects to the sign in index page" do
        request_callback
        expect(response).to redirect_to(sign_in_index_path)
      end

      describe "save the new user", "feature_allow_user_creation": true do
        it "creates a session for the new user" do
          request_callback
          expect(session[:dfe_sign_in_user]["dfe_sign_in_uid"]).to eq(user.dfe_sign_in_uid)
          expect(session[:dfe_sign_in_user]["email"]).to eq(user.email)

          expect(session[:dfe_sign_in_user]["first_name"]).to eq(user.first_name)
          expect(session[:dfe_sign_in_user]["last_name"]).to eq(user.last_name)
        end

        it "redirects to the trainees index page" do
          request_callback
          expect(response).to redirect_to(trainees_path)
        end

        it "saved non existing user to database" do
          expect { request_callback }.to change { User.count }
          .from(0).to(1)
        end

        it "created provider if needed" do
          expect { request_callback }.to change { Provider.count }
          .from(0).to(1)

          expect { request_callback }.to_not change { Provider.count }
          .from(1)
        end
      end
    end
  end
end
