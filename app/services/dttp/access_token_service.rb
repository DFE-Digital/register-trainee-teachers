module Dttp
  class AccessTokenService
    class AuthenticationClient
      include HTTParty

      MICROSOFT_LOGIN_URL = "https://login.microsoftonline.com".freeze

      base_uri MICROSOFT_LOGIN_URL
    end

    def self.call
      new.call
    end

    def call
      options = {
        body: {
          grant_type: "client_credentials",
          client_id: client_id,
          scope: scope,
          client_secret: client_secret,
        },
      }

      response = AuthenticationClient.post("/#{tenant_id}/oauth2/v2.0/token", options)
      JSON.parse(response.body)["access_token"]
    end

  private

    def tenant_id
      Settings.dttp.tenant_id
    end

    def client_id
      Settings.dttp.client_id
    end

    def scope
      Settings.dttp.scope
    end

    def client_secret
      Settings.dttp.client_secret
    end
  end
end
