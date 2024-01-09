# frozen_string_literal: true

class SelectPlacementSchoolForm
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::UrlHelper
  include GovukLinkHelper

  attr_accessor :slug, :school_id, :query, :trainee

  def initialize(trainee:, query:, placement_slug: nil)
    @trainee = trainee
    @query = query
    @slug = placement_slug
  end

  def search_results
    @search_results ||= SchoolSearch.call(query:)
  end

  def form_path
    if slug.present?
      trainee_placement_path(trainee_id: trainee.slug, id: slug)
    else
      trainee_placements_path(trainee_id: trainee.slug)
    end
  end

  def form_method
    slug.present? ? :patch : :post
  end

  def title
    if search_results.schools.empty?
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
