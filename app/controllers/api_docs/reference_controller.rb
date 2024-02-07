# frozen_string_literal: true

module ApiDocs
  class ReferenceController < ApiDocs::BaseController
    VERSIONS = %w[v0.1 v1.0].freeze
    CURRENT_VERSION = "v0.1"

    def show
      @version = api_version_param.nil? ? CURRENT_VERSION : api_version_param

      if VERSIONS.include?(@version)
        render#("api_docs/reference/v#{@version}/reference")
      else
        redirect_to(not_found_path)
      end
    end

  private

    def api_version_param
      params[:api_version]
    end
  end
end
