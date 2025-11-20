# frozen_string_literal: true

module Api
  class InfoController < Api::BaseController
    def show
      render(
        json: {
          status: "ok",
          version: {
            requested: api_version,
            latest: Settings.api.current_version,
          },
        },
      )
    end
  end
end
