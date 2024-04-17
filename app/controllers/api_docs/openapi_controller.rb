# frozen_string_literal: true

module ApiDocs
  class OpenapiController < ApplicationController
    layout false
    skip_before_action :authenticate

    def index
      response.set_header("Content-Security-Policy", "worker-src blob:")
    end
  end
end
