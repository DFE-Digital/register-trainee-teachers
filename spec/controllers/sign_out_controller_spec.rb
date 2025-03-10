# frozen_string_literal: true

require "rails_helper"

describe SignOutController do
  include DfESignInUserHelper

  let(:user) { create(:user) }

  let(:dfe_sign_in_user) do
    {
      "email" => user.email,
      "dfe_sign_in_uid" => user.dfe_sign_in_uid,
      "last_active_at" => Time.zone.now,
      "id_token" => "id_token",
      "provider" => provider,
    }
  end

  let(:request_index) do
    session["dfe_sign_in_user"] = dfe_sign_in_user
    get :index
  end

  describe "#signout" do
    context "existing DfE user" do
      let(:provider) { "dfe" }

      it "redirects to the session/end" do
        request_index
        expect(response).to redirect_to(dfe_logout_url)
      end
    end

    context "developer user" do
      let(:provider) { "developer" }

      it "redirects to the developer/sign-out" do
        request_index
        expect(response).to redirect_to("/auth/developer/sign-out")
      end
    end
  end

private

  def dfe_logout_url
    uri = URI("#{Settings.dfe_sign_in.issuer}/session/end")
    uri.query = {
      id_token_hint: "id_token",
      post_logout_redirect_uri: "#{request.base_url}/auth/dfe/sign-out",
    }.to_query
    uri.to_s
  end
end
