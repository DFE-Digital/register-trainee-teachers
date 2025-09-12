# frozen_string_literal: true

module SortBy
  class View < ApplicationComponent
    include Rails.application.routes.url_helpers

    attr_reader :items

    def initialize(items:)
      @items = items&.compact
    end

    def items_html
      items.map do |item|
        sort_param = item.parameterize.underscore
        if sort_param == current_sort_by
          item # Display item as plain text if it's the current sort parameter
        else
          item_link(item, sort_param)
        end
      end.join(" | ").html_safe
    end

  private

    def item_link(item, sort_param)
      helpers.govuk_link_to(item, url_for(helpers.request.params.merge(sort_by: sort_param)), class: "govuk-link--no-visited-state")
    end

    def current_sort_by
      helpers.request.params[:sort_by]
    end
  end
end
