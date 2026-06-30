# frozen_string_literal: true

module Autocomplete
  class BaseController < ::ApplicationController
  private

    def render_json_error(code: nil, message:, status: :internal_server_error)
      render(json: { code: code, error: message }.compact, status: status)
    end
  end
end
