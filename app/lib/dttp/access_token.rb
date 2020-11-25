# frozen_string_literal: true

module Dttp
  class AccessToken
    class Client
      include HTTParty
      base_uri "https://login.microsoftonline.com"
    end

    TOKEN_EXPIRY_TIME = 3599.seconds
    CACHED_TOKEN_EXPIRY_TIME = TOKEN_EXPIRY_TIME - 5.seconds

    REQUEST_BODY = {
      grant_type: "client_credentials",
      client_id: Settings.dttp.client_id,
      scope: Settings.dttp.scope,
      client_secret: Settings.dttp.client_secret,
    }.freeze

    def self.fetch
      Rails.cache.fetch("dttp-access-token", expires_in: CACHED_TOKEN_EXPIRY_TIME) do
        response = Client.post("/#{Settings.dttp.tenant_id}/oauth2/v2.0/token", body: REQUEST_BODY)
        JSON.parse(response.body)["access_token"]
      end
    end
  end
end
