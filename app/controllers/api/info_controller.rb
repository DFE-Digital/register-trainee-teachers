# frozen_string_literal: true

module Api
  class InfoController < Api::BaseController
    def show
      render(json: { status: "ok", version: { requested: current_version, latest: "v2025.0-rc" } })
    end
  end
end
