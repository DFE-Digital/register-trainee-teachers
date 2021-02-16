# frozen_string_literal: true

module Trainees
  module SortLinks
    class View < GovukComponent::Base
      def sort_by_date_link
        sort_link(t("components.page_titles.trainees.sort_links.date_updated"), :date_updated)
      end

      def sort_by_last_name_link
        sort_link(t("components.page_titles.trainees.sort_links.last_name"), :last_name)
      end

    private

      def sort_link(name, sort_by)
        sorted_by?(sort_by) ? name : link_to(name, sort_path(sort_by), class: "govuk-link")
      end

      def sort_path(sort_by)
        request.path + "?" + request.query_parameters.merge(sort_by: sort_by).to_query
      end

      def sorted_by?(key)
        params[:sort_by]&.to_sym == key
      end
    end
  end
end
