# frozen_string_literal: true

module ApiDocs
  class BaseController < ::ApplicationController
    VERSIONS = %w[v0.1 v1.0].freeze
    CURRENT_VERSION = "v0.1"

    layout "api_docs/pages"
    skip_before_action :authenticate
    before_action { require_feature_flag(:register_api) }
    before_action :check_version
    helper_method :api_version

  private

    def check_version
      unless VERSIONS.include?(api_version)
        redirect_to(not_found_path)
      end
    end

    def api_version
      params[:api_version] || CURRENT_VERSION
    end
  end
end
