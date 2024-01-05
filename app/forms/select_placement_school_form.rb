# frozen_string_literal: true

class SelectPlacementSchoolForm
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks

  attr_accessor :school_id, :query, :trainee

  # alias_method :to_param, :slug

  def initialize(trainee:, query:)
    @trainee = trainee
    @query = query
  end

  def search_results
    @search_results ||= SchoolSearch.call(query:)
  end
end
