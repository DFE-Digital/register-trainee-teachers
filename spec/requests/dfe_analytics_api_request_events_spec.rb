# frozen_string_literal: true

require "rails_helper"

class ApiRequestTestController < Api::BaseController
  skip_before_action :update_last_used_at_on_token!
  def test
    render plain: "Booyah"
  end

  def authenticate!
    @current_provider = Provider.last
  end

  attr_reader :current_provider
end

describe "sending request events" do
  let!(:provider) { create(:provider) }
  let(:headers) do
    {
      "HTTP_USER_AGENT" => "Toaster/1.23",
      "HTTP_REFERER" => "https://example.com/",
      "X-Request-Id" => "iamauuid",
    }
  end

  before do
    enable_features("register_api")

    Rails.application.routes.draw do
      get "/test", to: "api_request_test#test"
    end
  end

  after do
    Rails.application.reload_routes!
  end

  context "feature is enabled" do
    before { enable_features("google.send_data_to_big_query") }

    it "does send to big query" do
      expect {
        get "/test?foo=bar", headers:
      }.to(have_sent_analytics_event_types(:api_request))
    end
  end

  context "feature is disabled" do
    before {
      disable_features("google.send_data_to_big_query")
    }

    it "doesn't send to big query" do
      expect {
        get "/test?foo=bar", headers:
      }.not_to(have_sent_analytics_event_types(:api_request))
    end
  end
end
