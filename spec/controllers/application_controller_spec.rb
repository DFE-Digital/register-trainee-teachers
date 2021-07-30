# frozen_string_literal: true

require "rails_helper"

describe ApplicationController, type: :controller do
  let!(:user) { create(:user, email: "Lovely.User@example.com") }

  let(:dfe_sign_in_user) do
    {
      "email" => dfe_sign_in_email,
      "last_active_at" => 1.hour.ago,
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
      let(:dfe_sign_in_email) { "LOVELY.USER@example.com" }

      it "still finds the user via case insensitive search" do
        get :index
        expect(response.body).to include "found user: Lovely.User@example.com"
      end
    end

    context "if the email doesn't match at all" do
      let(:dfe_sign_in_email) { "lovely.youser@example.com" }

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
