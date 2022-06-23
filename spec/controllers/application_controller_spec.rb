# frozen_string_literal: true

require "rails_helper"

describe ApplicationController, type: :controller do
  let!(:user) do
    create(
      :user,
      email: "Lovely.User@example.com",
      dfe_sign_in_uid: "6dd394f1-df7d-45f1-976e-687190390d62",
    )
  end
  let(:dfe_sign_in_uid) { "6dd394f1-df7d-45f1-976e-687190390d62" }
  let(:dfe_sign_in_user) do
    {
      "email" => "Lovely.User@example.com",
      "last_active_at" => 1.hour.ago,
      "dfe_sign_in_uid" => dfe_sign_in_uid,
    }
  end

  before do
    session["dfe_sign_in_user"] = dfe_sign_in_user
  end

  describe "current_user" do
    controller do
      skip_before_action :authenticate

      def index
        if current_user
          render plain: "found user: #{current_user.email}"
        else
          render plain: "current user is nil!"
        end
      end
    end

    context "if the email in session is not a case sensitive match for a user" do
      let(:dfe_sign_in_uid) { "6dd394f1-DF7D-45f1-976E-687190390d62" }

      it "still finds the user via case insensitive search" do
        get :index
        expect(response.body).to include "found user: Lovely.User@example.com"
      end
    end

    context "if the email doesn't match at all" do
      let(:dfe_sign_in_uid) { "240e28fb-1164-4054-9323-7d058d63f9b2" }

      it "returns nil" do
        get :index
        expect(response.body).to include "current user is nil!"
      end
    end

    context "there is a user but they have been deleted" do
      let(:dfe_sign_in_email) { user.email }

      before do
        user.discard!
      end

      it "returns nil" do
        get :index
        expect(response.body).to include "current user is nil!"
      end
    end
  end
end
