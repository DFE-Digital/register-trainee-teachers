# frozen_string_literal: true

module Api
  module V20250Rc
    class NationalityAttributes
      include ActiveModel::Model
      include ActiveModel::Attributes

      ATTRIBUTES = %i[name].freeze

      attribute :nationality_id, :integer

      def initialize(attributes = {})
        super({})
        return if attributes.blank?

        nationality = lookup_nationality_by_name(attributes[:name])

        if nationality
          self.nationality_id = nationality.id
        elsif attributes[:name].present?
          errors.add(:name, "Could not find a nationality with the name #{attributes[:name]}")
        end
      end

    private

      def lookup_nationality_by_name(name)
        Nationality.find_by("LOWER(name) = ?", name.strip.downcase)
      end
    end
  end
end
