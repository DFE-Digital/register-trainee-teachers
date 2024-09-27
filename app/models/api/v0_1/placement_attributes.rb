# frozen_string_literal: true

module Api
  module V01
    class PlacementAttributes
      include ActiveModel::Model
      include ActiveModel::Attributes

      URN_REGEX = /\A[0-9]{6}\z/

      ATTRIBUTES = %i[
        urn
        name
        address
        postcode
      ].freeze.each { |attr| attribute(attr) }

      INTERNAL_ATTRIBUTES = %i[
        school_id
      ].freeze.each { |attr| attribute(attr) }

      validates :urn, format: { with: URN_REGEX }, if: -> { urn.present? }
      validates :name, presence: true
      validates :postcode, postcode: true

      def self.from_placement(placement)
        new(placement.attributes)
      end

      def assign_attributes(new_attributes)
        if (school = School.find_by(urn: new_attributes[:urn]))
          new_attributes[:school_id]   = school.id
          new_attributes[:urn]         = school.urn
          new_attributes[:name]      ||= school.name
          new_attributes[:postcode]  ||= school.postcode

          super
        end

        super(new_attributes.select { |k, _v| ATTRIBUTES.include?(k.to_sym) })
      end
    end
  end
end
