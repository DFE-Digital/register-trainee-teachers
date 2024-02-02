module Api
  class PlacementAttributes
    include ActiveModel::Model
    include PlacementValidations

    ATTRIBUTES = %i[
      address
      name
      postcode
      urn
      school_id
    ].freeze

    attr_accessor(*ATTRIBUTES)
  end
end
