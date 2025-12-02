# frozen_string_literal: true

module TechDocs
  class Availability
    PATHS = %r{\A/(api-docs|reference-data)/(v[\d.]+-?\w*)}

    def initialize(app)
      @app = app
    end

    def call(env)
      path = env["PATH_INFO"]

      if (match = path.match(PATHS))
        version = match[2]
        return [404, {}, ["Not found"]] unless Settings.api.allowed_versions.include?(version)
      end

      @app.call(env)
    end
  end
end
