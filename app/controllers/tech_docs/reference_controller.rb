# frozen_string_literal: true

module TechDocs
  class ReferenceController < TechDocs::BaseController
    before_action :check_version
    helper_method :api_version

    layout "tech_docs/pages"

    def show; end

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
