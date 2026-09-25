# frozen_string_literal: true

module OpenApi
  class Availability
    PATH = %r{\A/openapi/(v[\d.]+-?\w*)\.ya?ml\z}

    def initialize(app)
      @app = app
    end

    def call(env)
      path = env["PATH_INFO"]

      if (match = path.match(PATH))
        version = match[1]
        return [404, {}, ["Not found"]] unless Settings.api.allowed_versions.include?(version)
      end

      @app.call(env)
    end
  end
end
