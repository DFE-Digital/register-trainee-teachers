# frozen_string_literal: true

require "rails_helper"

RSpec.describe "DfE Sign-in callback" do
  include DfESignInUserHelper

  let(:user) { create(:user) }

  before do
    user_exists_in_dfe_sign_in(user:)
  end

  after do
    OmniAuth.config.mock_auth.clear
  end

  describe "GET /auth/dfe/callback" do
    it "resets the session cookie when signing in to prevent session fixation" do
      get root_path

      original_session_cookie = response.cookies["_register_trainee_teachers_session"]

      get "/auth/dfe/callback"

      authenticated_session_cookie = response.cookies["_register_trainee_teachers_session"]

      expect(authenticated_session_cookie).not_to eq(original_session_cookie)
      expect(session["dfe_sign_in_user"]).to be_present
    end

    it "preserves the requested path when resetting the session during sign in" do
      requested_path = "/bulk-update/add-details/new"

      get requested_path

      expect(session[:requested_path]).to eq(requested_path)

      get "/auth/dfe/callback"

      expect(response).to redirect_to(requested_path)
    end
  end
end
