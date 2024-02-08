# frozen_string_literal: true

module ApiDocs
  class PagesController < ApiDocs::BaseController
    DEFAULT_PAGE = "home"

    def show
      render(params[:page] || DEFAULT_PAGE)
    end
  end
end
