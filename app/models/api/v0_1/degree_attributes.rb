# frozen_string_literal: true

module Api
  module V01
    class DegreeAttributes
      include ActiveModel::Model
      include ActiveModel::Attributes

      ATTRIBUTES = %i[
        id
        country
        grade
        grade_uuid
        locale_code
        uk_degree
        uk_degree_uuid
        non_uk_degree
        subject
        subject_uuid
        institution
        institution_uuid
        graduation_year
        other_grade
      ].freeze

      ATTRIBUTES.each do |attr|
        attribute attr
      end

      attr_reader :existing_degrees

      def initialize(attributes, trainee: nil)
        super(attributes)

        @existing_degrees = if trainee.present?
                              if id.present?
                                trainee.degrees.where.not(id:)
                              else
                                trainee.degrees
                              end
                            end
      end

      validate :check_for_duplicates

      def self.from_degree(degree, trainee:)
        new(
          DegreeSerializer.new(degree)
            .as_hash
            .merge(id: degree.id).select { |k, _v| ATTRIBUTES.include?(k.to_sym) }
            .as_json,
          trainee:,
        )
      end

      def duplicates?
        existing_degrees&.exists?(
          hesa_mapped_degree_attributes.slice(
            :subject,
            :graduation_year,
            :country,
            :uk_degree,
            :non_uk_degree,
            :grade,
          ).compact,
        )
      end

    private

      def hesa_mapped_degree_attributes
        HesaMapper::DegreeAttributes.new(attributes.symbolize_keys).call
      end

      def check_for_duplicates
        errors.add(:base, :duplicates) if duplicates?
      end
    end
  end
end
