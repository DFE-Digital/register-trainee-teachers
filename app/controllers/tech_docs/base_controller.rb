# frozen_string_literal: true

module TechDocs
  class BaseController < ::ApplicationController
    layout "tech_docs/pages"
    skip_before_action :authenticate
    before_action :set_full_width
    attr_accessor :full_width

  private

    def set_full_width
      @full_width = true
    end
  end
end
