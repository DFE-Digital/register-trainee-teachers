# frozen_string_literal: true

class SelectPlacementSchoolForm
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks

  attr_accessor :slug, :school_id, :query, :trainee

  validates :school_id, presence: true

  def initialize(trainee:, query:, placement_slug: nil)
    @trainee = trainee
    @query = query
    @slug = placement_slug
  end
end
