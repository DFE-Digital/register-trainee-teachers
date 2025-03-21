# frozen_string_literal: true

module ApiDocs
  class BaseController < ::ApplicationController
    layout "api_docs/pages"

    skip_before_action :authenticate
    before_action { require_feature_flag(:register_api) }
    before_action :check_version
    helper_method :api_version

  private

    def check_version
      unless Settings.api.allowed_versions.include?(api_version)
        redirect_to(not_found_path)
      end
    end

    def api_version
      params[:api_version] || Settings.api.current_version
    end
  end
end
