# frozen_string_literal: true

module ApplyApi
  class Client
    include HTTParty
    base_uri Settings.apply_api.base_url
    headers "Accept" => "application/json",
            "Content-Type" => "application/json",
            "Authorization" => -> { "Bearer #{Settings.apply_api.auth_token}" },
            "User-Agent" => "Register for teacher training (#{Settings.environment.name})"
  end
end
