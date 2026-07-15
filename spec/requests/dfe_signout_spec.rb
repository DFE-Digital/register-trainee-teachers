# frozen_string_literal: true

require "rails_helper"

RSpec.describe "DfE Sign out" do
  include DfESignInUserHelper

  let(:user) { create(:user) }

  before do
    user_exists_in_dfe_sign_in(user:)
  end

  after do
    OmniAuth.config.mock_auth.clear
  end

  describe "GET /auth/dfe/sign-out" do
    it "destroys the session when signing out" do
      get "/auth/dfe/callback"
      signed_in_session_cookie = response.cookies["_register_trainee_teachers_session"]

      expect(session["dfe_sign_in_user"]).to be_present

      get "/auth/dfe/sign-out"
      signed_out_session_cookie = response.cookies["_register_trainee_teachers_session"]

      expect(signed_out_session_cookie).not_to eq(signed_in_session_cookie)
    end
  end
end
