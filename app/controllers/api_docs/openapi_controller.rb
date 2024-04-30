# frozen_string_literal: true

module ApiDocs
  class OpenapiController < ApplicationController
    layout false
    skip_before_action :authenticate
    helper_method :version

    def index
      response.set_header("Content-Security-Policy", "worker-src blob:")
    end

  private

    def version
      params.fetch("version", "v0.1")
    end
  end
end
