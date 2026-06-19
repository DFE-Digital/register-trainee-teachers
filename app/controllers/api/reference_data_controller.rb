# frozen_string_literal: true

module Api
  class ReferenceDataController < Api::BaseController
    def show
      render(**Api::ReferenceDataResponse.call(version: api_version, field: params[:field]))
    rescue Api::ReferenceDataResponse::UnsupportedVersionError
      render_not_found(message: "Reference data is not available for version '#{api_version}'")
    rescue KeyError
      render_not_found(message: "Reference data field '#{params[:field]}' not found")
    end
  end
end
