# frozen_string_literal: true

module TechDocs
  class TrailingSlashRedirect
    PATHS = %w[/api-docs /csv-docs /reference-data].freeze

    def initialize(app)
      @app = app
    end

    def call(env)
      path = env["PATH_INFO"]

      return [301, { "Location" => "#{path}/" }, []] if PATHS.include?(path)

      @app.call(env)
    end
  end
end
