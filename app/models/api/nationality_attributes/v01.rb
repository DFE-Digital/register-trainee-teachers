# frozen_string_literal: true

module Api
  module NationalityAttributes
    class V01
      include ActiveModel::Model
      include ActiveModel::Attributes

      ATTRIBUTES = %i[name].freeze

      attribute :nationality_id, :integer

      def initialize(attributes = {})
        super({})

        nationality =
          if attributes[:name].present?
            lookup_nationality_by_name(attributes[:name])
          elsif attributes[:hesa_nationality_code].present?
            lookup_nationality_by_name(
              RecruitsApi::CodeSets::Nationalities::MAPPING[attributes[:hesa_nationality_code]],
            )
          end

        if nationality
          self.nationality_id = nationality.id
        elsif attributes[:name].present?
          errors.add(:name, "Could not find a nationality with the name #{attributes[:name]}")
        else
          errors.add(:name, "Could not find a nationality with the HESA code #{attributes[:hesa_nationalality_code]}")
        end
      end

    private

      def lookup_nationality_by_name(name)
        Nationality.find_by("LOWER(name) = ?", name.strip.downcase)
      end
    end
  end
end
