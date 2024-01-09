# frozen_string_literal: true

class SelectPlacementSchoolForm
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks
  include ActionView::Helpers::TextHelper
  include Rails.application.routes.url_helpers

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
      "#{pluralize(search_results.schools.size, 'result')} found"
    end
  end
end
