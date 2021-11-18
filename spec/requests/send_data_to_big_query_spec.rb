# frozen_string_literal: true

require "rails_helper"

class UnauthenticatedTestController < ::ApplicationController
  skip_before_action :authenticate

  def test
    render plain: "Booyah"
  end
end

class TestController < ::ApplicationController
  def test
    render plain: "Booyah"
  end

  def sign_in_path
    "/"
  end

  def authenticate
    @current_user = User.last
  end

  attr_reader :current_user
end

describe "sending request events", type: :request do
  let!(:user) { create(:user) }
  let(:headers) do
    {
      "HTTP_USER_AGENT" => "Toaster/1.23",
      "HTTP_REFERER" => "https://example.com/",
      "X-Request-Id" => "iamauuid",
    }
  end

  before do
    Rails.application.routes.draw do
      get "/test", to: "test#test"
      get "/unauthenticated_test", to: "unauthenticated_test#test"
    end
  end

  after do
    enable_features("use_dfe_sign_in")
    Rails.application.reload_routes!
  end

  context "feature is enabled" do
    before { enable_features("google.send_data_to_big_query") }

    it "does send to big query" do
      expect {
        get "/test?foo=bar", headers: headers
      }.to(have_enqueued_job(BigQuery::SendEventJob))
    end

    context "controller doesn't have a current_user" do
      it "does send to big query" do
        expect {
          get "/unauthenticated_test?foo=bar", headers: headers
        }.to(have_enqueued_job(BigQuery::SendEventJob))
      end
    end
  end

  context "feature is disabled" do
    before {
      disable_features("google.send_data_to_big_query", "use_dfe_sign_in")
    }

    it "doesn't send to big query" do
      expect {
        get "/test?foo=bar", headers: headers
      }.not_to(have_enqueued_job(BigQuery::SendEventJob))
    end
  end
end
