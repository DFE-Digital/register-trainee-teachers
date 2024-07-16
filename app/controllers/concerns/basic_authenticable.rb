# frozen_string_literal: true

# Enforces HTTP Basic Auth
module BasicAuthenticable
  class << self
    WHITELISTED_PATHS = %w[/metrics].freeze

    def required?(path)
      Settings.features.basic_auth && !whitelisted?(path)
    end

    def whitelisted?(path)
      WHITELISTED_PATHS.include?(path)
    end

    def authenticate(username, password)
      validate(username, password)
    end

    def validate(username, password)
      utils.secure_compare(::Digest::SHA256.hexdigest(auth_username), ::Digest::SHA256.hexdigest(username)) &
        utils.secure_compare(::Digest::SHA256.hexdigest(auth_password), ::Digest::SHA256.hexdigest(password))
    end

    def auth_username
      @auth_username ||= Settings.basic_auth.username
    end

    def auth_password
      @auth_password ||= Settings.basic_auth.password
    end

    def utils
      ActiveSupport::SecurityUtils
    end
  end
end
