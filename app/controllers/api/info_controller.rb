# frozen_string_literal: true

module Api
  class InfoController < Api::BaseController
    def show
      render(json: { status: "ok", version: { requested: current_version, next: "v1.0" } })
    end
  end
end
