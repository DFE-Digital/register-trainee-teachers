# frozen_string_literal: true

module Api
  module V20250Rc
    class PlacementAttributes
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Api::ErrorAttributeAdapter

      attr_accessor :record_source

      URN_REGEX = /\A[0-9]{6}\z/

      ATTRIBUTES = %i[
        urn
        name
        postcode
      ].freeze.each { |attr| attribute(attr) }

      INTERNAL_ATTRIBUTES = %i[
        school_id
      ].freeze.each { |attr| attribute(attr) }

      validates :urn, format: { with: URN_REGEX }, if: -> { urn.present? }
      validates :name, presence: true, if: -> { school_id.nil? && !School.exists?(urn:) }
      validates :postcode, postcode: true

      def self.from_placement(placement)
        new(
          placement.attributes.select do |k, _v|
            ATTRIBUTES.include?(k.to_sym) || INTERNAL_ATTRIBUTES.include?(k.to_sym)
          end,
        )
      end

      def initialize(params, record_source: nil)
        super(params)
        self.record_source = record_source
      end

      def assign_attributes(new_attributes)
        if new_attributes.key?("urn") && (school = School.find_by(urn: new_attributes["urn"]))
          new_attributes["urn"]       = nil
          new_attributes["name"]      = nil
          new_attributes["postcode"]  = nil
          new_attributes["school_id"] = school.id
        else
          new_attributes["school_id"] = nil
        end

        super(
          new_attributes.select do |k, _v|
            ATTRIBUTES.include?(k.to_sym) || INTERNAL_ATTRIBUTES.include?(k.to_sym)
          end
        )
      end
    end
  end
end
