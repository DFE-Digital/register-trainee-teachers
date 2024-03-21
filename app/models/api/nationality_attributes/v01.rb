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

        nationality = attributes[:name].present? ? Nationality.find_by("LOWER(name) = ?", attributes[:name].strip.downcase) : nil

        if nationality
          self.nationality_id = nationality.id
        else
          errors.add(:name, "Could not find a nationality with the name #{attributes[:name]}")
        end
      end
    end
  end
end
