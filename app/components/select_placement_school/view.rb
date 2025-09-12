# frozen_string_literal: true

module SelectPlacementSchool
  class View < ApplicationComponent
    include ApplicationHelper
    include SchoolHelper

    attr_accessor :model, :slug, :query, :trainee

    def initialize(model:, slug:, query:, trainee:)
      @model = model
      @trainee = trainee
      @query = query
      @slug = slug
    end

    def search_results
      @search_results ||= SchoolSearch.call(query:)
    end

    def form_path
      if slug.present?
        trainee_placement_school_search_path(trainee_id: trainee.slug, id: slug)
      else
        trainee_placement_school_search_index_path(trainee_id: trainee.slug)
      end
    end

    def form_method
      slug.present? ? :patch : :post
    end

    def title
      if search_results.total_count.zero?
        "No results found for ‘#{query}’"
      else
        "#{pluralize(search_results.total_count, 'result')} found"
      end
    end

    def hint_text
      content_tag(:p, class: "govuk-body") do
        if search_results.total_count.zero?
          govuk_link_to("Change your search", search_again_path)
        elsif search_results.total_count > SchoolSearch::DEFAULT_LIMIT
          content_tag(:span, "Showing the first #{SchoolSearch::DEFAULT_LIMIT} results. ").concat(
            govuk_link_to("Try narrowing down your search", search_again_path).concat(
              content_tag(:span, " if the school you’re looking for is not listed."),
            ),
          )
        else
          govuk_link_to("Change your search", search_again_path).concat(
            content_tag(:span, " if the school you’re looking for is not listed."),
          )
        end
      end
    end

    def search_again_path
      if slug.present?
        edit_trainee_placement_path(trainee_id: trainee.slug, id: slug)
      else
        new_trainee_placement_path(trainee_id: trainee.slug)
      end
    end
  end
end
