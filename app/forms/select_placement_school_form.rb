# frozen_string_literal: true

class SelectPlacementSchoolForm
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks
  include Rails.application.routes.url_helpers

  attr_accessor :slug, :school_id, :query, :trainee

  # alias_method :to_param, :slug

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
end
