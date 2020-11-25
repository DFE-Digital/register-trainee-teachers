# frozen_string_literal: true

module Dttp
  class Client
    include HTTParty
    base_uri Settings.dttp.api_base_url
    headers "Accept" => "application/json",
            "Content-Type" => "application/json;odata.metadata=minimal",
            "Authorization" => "Bearer #{AccessToken.fetch}"
  end
end
