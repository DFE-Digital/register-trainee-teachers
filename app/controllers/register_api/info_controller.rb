# frozen_string_literal: true

module RegisterApi
  class InfoController < RegisterApi::ApplicationController
    def show
      render(json: { status: "ok" })
    end
  end
end
