# frozen_string_literal: true

module Dttp
  class AccessToken
    class Client
      include HTTParty
      base_uri "https://login.microsoftonline.com"
    end

    REQUEST_BODY = {
      grant_type: "client_credentials",
      client_id: Settings.dttp.client_id,
      scope: Settings.dttp.scope,
      client_secret: Settings.dttp.client_secret,
    }.freeze

    def self.fetch
      response = Client.post("/#{Settings.dttp.tenant_id}/oauth2/v2.0/token", body: REQUEST_BODY)
      JSON.parse(response.body)["access_token"]
    end
  end
end
