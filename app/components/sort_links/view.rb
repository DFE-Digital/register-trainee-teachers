# frozen_string_literal: true

module SortLinks
  class View < ApplicationComponent
    def sort_by_date_link
      default_sort_link(t("components.page_titles.trainees.sort_links.date_updated"), :date_updated)
    end

    def sort_by_last_name_link
      sort_link(t("components.page_titles.trainees.sort_links.last_name"), :last_name)
    end

  private

    def default_sort_link(name, sort_by)
      return tag.span(name, class: "app-sort-links__item--no_padding") if params[:sort_by].blank?

      sort_link(name, sort_by)
    end

    def sort_link(name, sort_by)
      sorted_by?(sort_by) ? tag.span(name, class: "app-sort-links__item--no_padding") : govuk_link_to(name, sort_path(sort_by), class: "app-sort-links__item govuk-link govuk-link--no-visited-state")
    end

    def sort_path(sort_by)
      "#{request.path}?#{request.query_parameters.merge(sort_by:).to_query}"
    end

    def sorted_by?(key)
      params[:sort_by]&.to_sym == key
    end
  end
end
