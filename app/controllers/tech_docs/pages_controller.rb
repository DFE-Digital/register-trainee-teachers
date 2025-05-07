# frozen_string_literal: true

module TechDocs
  class PagesController < TechDocs::BaseController
    layout "tech_docs/pages"

    DEFAULT_PAGE = "home"

    def show
      render(params[:page] || DEFAULT_PAGE)
    end
  end
end
