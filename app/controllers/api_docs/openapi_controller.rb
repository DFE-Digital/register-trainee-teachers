# frozen_string_literal: true

module ApiDocs
  class OpenapiController < ApiDocs::BaseController
    layout false

    def show
      response.set_header("Content-Security-Policy", "worker-src blob:")
    end
  end
end
