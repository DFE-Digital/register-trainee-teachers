# frozen_string_literal: true

module Api
  class PlacementAttributes
    include ActiveModel::Model
    include ActiveModel::Attributes
    include PlacementValidations

    ATTRIBUTES = %i[
      address
      name
      postcode
      urn
      school_id
    ].freeze

    ATTRIBUTES.each do |attr|
      attribute attr
    end
  end
end
