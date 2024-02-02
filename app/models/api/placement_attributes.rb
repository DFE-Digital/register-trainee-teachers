module Api
  class PlacementAttributes
    include ActiveModel::Model

    ATTRIBUTES = %i[
      address
      name
      postcode
      urn
      school_id
    ].freeze

    validates :name, presence: true
  end
end
