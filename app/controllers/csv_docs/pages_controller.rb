# frozen_string_literal: true

module CsvDocs
  class PagesController < CsvDocs::BaseController
    DEFAULT_PAGE = "add_trainees"

    def show
      render DEFAULT_PAGE
    end
  end
end
